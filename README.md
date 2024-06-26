
<body>
  <h1>Flight and Weather Dashboard Proj</h1>

  <h2>선정 이유 및 수집한 자료</h2>
  <ul>
    <li><strong>선정 이유:</strong> 제주의 날씨에 따른 항공기 지연 및 결항 이슈가 잦아서, 날씨와 항공사 가격을 한 눈에 비교하고 싶은 필요성을 느꼈습니다.</li>
    <li><strong>날씨 데이터:</strong> 네이버 날씨 <a href="https://weather.naver.com/">https://weather.naver.com/</a>에서 날씨, 기온, 강수량 등의 정보를 웹스크래핑을 통해 수집하였습니다.</li>
    <li><strong>항공편 데이터:</strong> 네이버 항공권 <a href="https://flight.naver.com/">https://flight.naver.com/</a>에서 항공편 정보(가격, 출발 시간, 도착 시간, 항공사 등)를 웹스크래핑을 통해 수집하였습니다.</li>
  </ul>

  <h2>대시보드 설명</h2>
  <ul>
    <li><strong>UI 구성:</strong> Shiny의 <code>fluidPage</code>와 <code>sidebarLayout</code>을 사용하여 사용자가 날짜, 출발지 및 도착지를 선택할 수 있습니다.</li>
    <li><strong>Server 구성:</strong> <code>observeEvent</code>를 이용하여 데이터 업데이트 버튼을 정의하였습니다. 사용자가 선택한 출발지와 도착지에 따라 항공 데이터를 필터링하고, 테이블과 플롯으로 출력합니다.</li>
    <li><strong>플롯 및 테이블:</strong> 각 탭에서는 항공 데이터 테이블과 가격 분포 플롯, 날씨 데이터 테이블과 온도 변화 플롯을 제공합니다.</li>
  </ul>

  <h2>향후 활용 방안</h2>
  <ul>
    <li><strong>출발지 및 도착지 변경 설정 가능:</strong> 사용자가 선택할 수 있는 설정을 추가하여, 항공 데이터와 날씨 데이터의 상관관계를 분석할 수 있습니다.</li>
    <li><strong>날씨 예보와 비행 스케줄 시각화:</strong> 지연 가능성을 예측하기 위해 날씨 예보와 비행 스케줄을 한 눈에 시각화하는 대시보드를 개발할 계획입니다.</li>
  </ul>
</body>
</html>
