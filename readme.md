# SOCKS5 프록시 iOS 구현
- `NWConnection`를 활용한 Swift 네트워크 패킷 프로그래밍
- LAN으로 `Personal Hotspot` 이용 시, iOS의 Network Interface는 `bridge100`이용해서 접근

## TODO

### AUTH
- [x] `0x00`: No authentication
- [ ] `0x02`: Username/password


### Client connection request 구현
- [x] `0x01`: establish a TCP/IP stream connection
- [ ] `0x02`: establish a TCP/IP port binding
- [ ] `0x03`: associate a UDP port

### Test
- [x] iOS에서 작동 확인
