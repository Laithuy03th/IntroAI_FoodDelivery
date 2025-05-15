package com.example.demo.services;

import java.util.*;

public class AStarPathFinder {
    public static class Node implements Comparable<Node> {
        public int x, y;
        public double g, h;
        public Node parent;

        public Node(int x, int y) {
            this.x = x;
            this.y = y;
            this.g = 0;
            this.h = 0;
            this.parent = null;
        }

        public double f() {
            return g + h;
        }

        @Override
        public int compareTo(Node o) {
            return Double.compare(this.f(), o.f());
        }

        @Override
        public boolean equals(Object o) {
            if (this == o)
                return true;
            if (!(o instanceof Node))
                return false;
            Node n = (Node) o;
            return x == n.x && y == n.y;
        }

        @Override
        public int hashCode() {
            return Objects.hash(x, y);
        }
    }

    private int[][] grid;
    private int rows, cols;

    public AStarPathFinder(int[][] grid) {
        this.grid = grid;
        this.rows = grid.length;
        this.cols = grid[0].length;
    }

    public List<Node> findPath(int startX, int startY, int endX, int endY) {
        Node start = new Node(startX, startY);
        Node end = new Node(endX, endY);
        PriorityQueue<Node> open = new PriorityQueue<>();
        Set<Node> closed = new HashSet<>();
        open.add(start);
        while (!open.isEmpty()) {
            Node current = open.poll();
            if (current.equals(end)) {
                return reconstructPath(current);
            }
            closed.add(current);
            for (int[] dir : new int[][] { { 0, 1 }, { 1, 0 }, { 0, -1 }, { -1, 0 } }) {
                int nx = current.x + dir[0], ny = current.y + dir[1];
                if (nx < 0 || ny < 0 || nx >= rows || ny >= cols || grid[nx][ny] == 1)
                    continue;
                Node neighbor = new Node(nx, ny);
                if (closed.contains(neighbor))
                    continue;
                double tentativeG = current.g + 1;
                boolean inOpen = open.contains(neighbor);
                if (!inOpen || tentativeG < neighbor.g) {
                    neighbor.g = tentativeG;
                    neighbor.h = Math.abs(nx - endX) + Math.abs(ny - endY);
                    neighbor.parent = current;
                    if (!inOpen)
                        open.add(neighbor);
                }
            }
        }
        return Collections.emptyList();
    }

    private List<Node> reconstructPath(Node end) {
        List<Node> path = new ArrayList<>();
        Node current = end;
        while (current != null) {
            path.add(current);
            current = current.parent;
        }
        Collections.reverse(path);
        return path;
    }
}
