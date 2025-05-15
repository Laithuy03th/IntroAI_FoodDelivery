package com.example.demo.controller.client;

import com.example.demo.domain.Order;
import com.example.demo.services.AStarPathFinder;
import com.example.demo.repository.OrderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;

import java.util.*;

@RestController
@RequestMapping("/api/delivery")
public class DeliveryController {
    @Autowired
    private OrderRepository orderRepository;

    private int[][] map = new int[25][25];

    private int[] addressToGrid(String address, boolean isRestaurant) {
        if (isRestaurant)
            return new int[] { 0, 0 }; // Nhà hàng ở góc trên trái
        int hash = Math.abs(address.hashCode());
        int x = 1 + (hash % 24); // từ 1 đến 24 để không trùng [0,0]
        int y = 1 + ((hash / 10) % 24);
        return new int[] { x, y };
    }

    @GetMapping("/route/{orderId}")
    public ResponseEntity<?> getDeliveryRoute(@PathVariable Long orderId) {
        Optional<Order> orderOpt = orderRepository.findById(orderId);
        if (!orderOpt.isPresent()) {
            return ResponseEntity.badRequest().body("Order not found");
        }
        Order order = orderOpt.get();
        String restaurantAddress = "123 Thanh Xuân";
        String customerAddress = order.getReceiverAddress();
        int[] start = addressToGrid(restaurantAddress, true);
        int[] end = addressToGrid(customerAddress, false);

        AStarPathFinder pathFinder = new AStarPathFinder(map);
        List<AStarPathFinder.Node> path = pathFinder.findPath(start[0], start[1], end[0], end[1]);
        if (path.isEmpty()) {
            return ResponseEntity.ok("Không tìm được đường đi!");
        }
        List<Map<String, Integer>> route = new ArrayList<>();
        for (AStarPathFinder.Node node : path) {
            Map<String, Integer> point = new HashMap<>();
            point.put("x", node.x);
            point.put("y", node.y);
            route.add(point);
        }
        // Trả về địa chỉ người nhận
        Map<String, Object> result = new HashMap<>();
        result.put("route", route);
        result.put("customerAddress", customerAddress);
        return ResponseEntity.ok(result);
    }
}
