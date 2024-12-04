@preconcurrency import NIOCore
@preconcurrency import NIOPosix
@preconcurrency import NIOSSL
@preconcurrency import NIOHTTP1
@preconcurrency import NIOHTTP2

extension http {
    final class RequestHandler: ChannelInboundHandler, Sendable {
        public typealias InboundIn = HTTPServerRequestPart
        public typealias OutboundOut = HTTPServerResponsePart

        public func channelRead(context: ChannelHandlerContext & Sendable,
                                data: NIOAny) {
            guard case .end = self.unwrapInboundIn(data) else { return }

            context.eventLoop.execute {
                context.channel.getOption(HTTP2StreamChannelOptions.streamID).flatMap
                { (streamID) -> EventLoopFuture<Void> in
                    var headers = HTTPHeaders()
                    headers.add(name: "content-length", value: "5")
                    headers.add(name: "x-stream-id", value: String(Int(streamID)))

                    context.channel.write(
                      self.wrapOutboundOut(
                        HTTPServerResponsePart.head(
                          HTTPResponseHead(version: .init(major: 2, minor: 0),
                                           status: .ok,
                                           headers: headers))),
                      promise: nil)

                    var buffer = context.channel.allocator.buffer(capacity: 12)
                    buffer.writeStaticString("hello")
                    
                    context.channel.write(
                      self.wrapOutboundOut(
                        HTTPServerResponsePart.body(.byteBuffer(buffer))),
                      promise: nil)
                    
                    return context.channel.writeAndFlush(
                      self.wrapOutboundOut(HTTPServerResponsePart.end(nil)))
                }.whenComplete { _ in context.close(promise: nil) }
            }
        }
    }

    final class ErrorHandler: ChannelInboundHandler, Sendable {
        typealias InboundIn = Never

        func errorCaught(context: ChannelHandlerContext, error: Error) {
            print("Server received error: \(error)")
            context.close(promise: nil)
        }
    }

    public static func start() throws {
        let pkey = try NIOSSLPrivateKey(file: "./localhost.key", format: .pem)
        let cert = try NIOSSLCertificate(file: "./localhost.crt", format: .pem)
        
        let host = "127.0.0.1"
        let port: Int = 8080
        let htdocs = "./htdocs"
        
        let bindTarget: BindTo = .ip(host: host, port: port)
        
        enum BindTo {
            case ip(host: String, port: Int)
            case unixDomainSocket(path: String)
        }
                
        // Load private key
        let sslPrivateKey = NIOSSLPrivateKeySource.privateKey(pkey)
        
        // Load the certificate
        let sslCertificate = NIOSSLCertificateSource.certificate(cert)
        
        // Set up the TLS configuration
        var serverConfig = TLSConfiguration.makeServerConfiguration(
          certificateChain: [sslCertificate],
          privateKey: sslPrivateKey)
        
        serverConfig.applicationProtocols = ["h2"]
        
        // Configure the SSL context that is used by all SSL handlers.
        let sslContext = try! NIOSSLContext(configuration: serverConfig)
        
        let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
        let bootstrap = ServerBootstrap(group: group)
        
        // Specify backlog and enable SO_REUSEADDR for the server itself
          .serverChannelOption(ChannelOptions.backlog, value: 256)
          .serverChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET),
                                                     SO_REUSEADDR),
                               value: 1)
        
        // Set the handlers that are applied to the accepted Channels
          .childChannelInitializer { channel in
              // First, we need an SSL handler because HTTP/2 is almost always spoken over TLS.
              channel.pipeline.addHandler(
                NIOSSLServerHandler(context: sslContext)).flatMap {
                  // Right after the SSL handler, we can configure the HTTP/2 pipeline.
                  channel.configureHTTP2Pipeline(mode: .server)
                  {(streamChannel) -> EventLoopFuture<Void> in
                      // For every HTTP/2 stream that the client opens,
                      // we put in the `HTTP2ToHTTP1ServerCodec` which
                      // transforms the HTTP/2 frames to the HTTP/1 messages
                      // from the `NIOHTTP1` module.
                      streamChannel.pipeline.addHandler(
                        HTTP2FramePayloadToHTTP1ServerCodec()).flatMap
                      { () -> EventLoopFuture<Void> in
                          // And lastly, we put in our very basic HTTP server :).
                          streamChannel.pipeline.addHandler(RequestHandler())
                      }.flatMap { () -> EventLoopFuture<Void> in
                          streamChannel.pipeline.addHandler(ErrorHandler())
                      }
                  }
              }.flatMap {(_: HTTP2StreamMultiplexer) in
                  return channel.pipeline.addHandler(ErrorHandler())
              }
          }
        
        // Enable TCP_NODELAY and SO_REUSEADDR for the accepted Channels
          .childChannelOption(ChannelOptions.socket(IPPROTO_TCP, TCP_NODELAY), value: 1)
        
          .childChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET),
                                                    SO_REUSEADDR),
                              value: 1)
        
          .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 1)
        
        defer { try! group.syncShutdownGracefully() }

        let channel = try { () -> Channel in
            switch bindTarget {
            case .ip(let host, let port):
                return try bootstrap.bind(host: host, port: port).wait()
            case .unixDomainSocket(let path):
                return try bootstrap.bind(unixDomainSocketPath: path).wait()
            }
        }()
        
        print("Publishing \(htdocs) on \(channel.localAddress!)")
        
        // This will never unblock as we don't close the ServerChannel
        try channel.closeFuture.wait()
    }    
}
