<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %> 
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đường đi giao hàng</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
   

<style>
    .bg-light{
            background-color: #afc2d6;
        }
        body {
            background: #bcf4fa;
            min-height: 100vh;
        }
        
        
        .route-layout {
            max-width: 1200px;
        }
        .info-panel {
            background:rgb(240, 211, 243);
            border-radius: 18px;
            box-shadow: 0 2px 12px rgba(0,0,0,0.08);
            border: 1px solid #eee;
        }
        .address-box {
            background: #f1f3f6;
            border-radius: 6px;
            padding: 7px 12px;
            margin-top: 2px;
            color: #333;
            font-size: 15px;
            font-weight: 500;
        }
        .legend-list {
            border-top: 1px dashed #ccc;
            padding-top: 16px;
            margin-top: 12px;
            display: flex;
        }
        .legend-item {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 15px;
        }
        .legend-cell {
            /* display: inline-block; */
            width: 18px;
            height: 18px;
            margin-right: 8px;
            border-radius: 4px;
            border-width: 2px;
            border-style: solid;
            vertical-align: middle;
        }
        
        .grid {
            display: grid;
            grid-template-columns: repeat(25, minmax(18px, 1fr));
            grid-template-rows: repeat(25, minmax(18px, 1fr));
            gap: 2px;
            margin: 0 auto 30px auto;
            max-width: 650px;
            background: #8ecdce;
            border-radius: 10px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.04);
            padding: 14px;
        }
        .cell {
            width: 100%; height: 0; padding-bottom: 100%;
            background: #f1f1f1;
            border: 1px solid #e0e0e0;
            border-radius: 4px;
            box-sizing: border-box;
            transition: background 0.2s;
        }
        .cell.start { background: #007bff !important; color: #fff; border: 2px solid #0056b3; }
        .cell.end { background: #28a745 !important; color: #fff; border: 2px solid #1e7e34; }
        .cell.path { background: #ff6f00 !important; color: #fff; border: 2px solid #ff9800; }
        .cell.obstacle { background: #343a40 !important; }
        @media (max-width: 900px) {
            .route-layout .row {
                flex-direction: column;
            }
            .info-panel, .grid {
                margin: 0 auto 20px auto;
            }
        }
    </style>

</head>


    <body class="bg-light">
<div class="container py-4">
<div class="container route-layout mt-4">
  <div class="row justify-content-center">
    <div class="col-lg-4 col-md-5 mb-4">
      <div class="info-panel p-4 shadow-sm rounded-4">
        <h4 class="mb-3 text-primary fw-bold">Thông tin giao hàng</h4>
        <div class="mb-3">
          <span class="fw-semibold">Địa chỉ nhà hàng:</span>
          <div id="restaurantAddress" class="address-box">123 Thanh Xuân</div>
        </div>
        <div class="mb-3">
          <span class="fw-semibold">Địa chỉ người nhận:</span>
          <div id="customerAddress" class="address-box"></div>
        </div>
        <div class="legend-list mt-4">
          <div class="legend-item mb-2">
            <span class="cell start legend-cell"></span> <span>Nhà hàng</span>
          </div>
          <div class="legend-item mb-2">
            <span class="cell end legend-cell"></span> <span>Khách hàng</span>
          </div>
          <div class="legend-item">
            <span class="cell path legend-cell"></span> <span>Đường đi</span>
          </div>
        </div>
      </div>
      <div id="message" class="mt-3 text-danger fw-bold"></div>
    </div>
    <div class="col-lg-7 col-md-7">
      <div id="gridContainer" class="grid"></div>
    </div>
  </div>
</div>

    <script>
    function getOrderId() {
        const params = new URLSearchParams(window.location.search);
        return params.get('orderId');
    }

    const orderId = getOrderId();
   
    if (!orderId) {
        document.getElementById('message').textContent = 'Không tìm thấy orderId!';
    } else {
        const route_path = '/api/delivery/route/' + orderId;
        // fetch(`/api/delivery/route/${orderId}`)
        fetch(route_path)
            .then(res => res.json())
           
            .then(data => {
    if (typeof data === 'string') {
        document.getElementById('message').textContent = data;
        renderRoute([]); // Vẫn vẽ lưới trắng
        return;
    }
    // Nếu trả về mảng rỗng
    if (!data.route || !Array.isArray(data.route) || data.route.length === 0) {
        document.getElementById('message').textContent = 'Không tìm được đường đi!';
        renderRoute([]);
        return;
    }
    // Hiển thị địa chỉ người nhận
    document.getElementById('customerAddress').textContent = data.customerAddress || '';
    document.getElementById('message').textContent = '';
    renderRoute(data.route);
})
            
    }

    ////////

    function renderRoute(route) {
        // CHỈ cập nhật customerAddress nếu có trong localStorage
        const customerAddr = localStorage.getItem('lastReceiverAddress');
        if (customerAddr) {
            document.getElementById('customerAddress').textContent = customerAddr;
        }
        const grid = [];
        for (let i = 0; i < 25; i++) {
            grid[i] = [];
            for (let j = 0; j < 25; j++) grid[i][j] = '';
        }
        // Đánh dấu start, end, path
        if (route.length > 0) {
            const start = route[0];
            const end = route[route.length - 1];
            grid[start.x][start.y] = 'start';
            grid[end.x][end.y] = 'end';
            for (let i = 1; i < route.length - 1; i++) {
                grid[route[i].x][route[i].y] = 'path';
            }
        }
        // Render lưới
        const gridContainer = document.getElementById('gridContainer');
        gridContainer.innerHTML = '';
        for (let i = 0; i < 25; i++) {
            for (let j = 0; j < 25; j++) {
                const div = document.createElement('div');
                div.className = 'cell' + (grid[i][j] ? ' ' + grid[i][j] : '');
                gridContainer.appendChild(div);
            }
        }
    }
</script>
</body>
</html>