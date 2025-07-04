const http = require('http');
const os = require('os'); // 운영체제 정보에 접근하기 위한 모듈

const PORT = 8081;

// 서버 생성
const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain; charset=utf-8');

  // 클라이언트의 IP 주소 가져오기
  // 'x-forwarded-for' 헤더는 프록시 뒤에 있을 경우 실제 클라이언트 IP를 포함할 수 있습니다.
  // 없으면 req.connection.remoteAddress를 사용합니다.
  const clientIp = req.headers['x-forwarded-for'] || req.connection.remoteAddress;

  // 서버의 IP 주소 가져오기
  let serverIp = 'localhost'; // 기본값
  const networkInterfaces = os.networkInterfaces();
  for (const interfaceName in networkInterfaces) {
    const addresses = networkInterfaces[interfaceName];
    for (const address of addresses) {
      // IPv4 주소이고 내부 주소가 아닌 경우
      if (address.family === 'IPv4' && !address.internal) {
        serverIp = address.address;
        break;
      }
    }
    if (serverIp !== 'localhost') break; // 서버 IP를 찾았으면 루프 종료
  }

  const message = `Hello, World!\n클라이언트 IP: ${clientIp}\n서버 IP: ${serverIp}`;
  res.end(message);
});

// 서버 리스닝 시작
server.listen(PORT, () => {
  let serverIp = 'localhost';
  const networkInterfaces = os.networkInterfaces();
  for (const interfaceName in networkInterfaces) {
    const addresses = networkInterfaces[interfaceName];
    for (const address of addresses) {
      if (address.family === 'IPv4' && !address.internal) {
        serverIp = address.address;
        break;
      }
    }
    if (serverIp !== 'localhost') break;
  }
  console.log(`서버가 다음 주소에서 실행 중입니다: http://${serverIp}:${PORT}/`);
  console.log(`웹 브라우저에서 접속하려면 다음을 입력하세요: http://localhost:${PORT}/ 또는 http://${serverIp}:${PORT}/`);
});