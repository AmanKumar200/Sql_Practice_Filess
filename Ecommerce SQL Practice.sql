CREATE DATABASE EcommerceDB;
USE EcommerceDB;

CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    city VARCHAR(50),
    signup_date DATE
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    amount DECIMAL(10 , 2 ),
    FOREIGN KEY (customer_id)
        REFERENCES Customers (customer_id)
);

CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10 , 2 )
);

CREATE TABLE Order_Items (
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (order_id)
        REFERENCES Orders (order_id),
    FOREIGN KEY (product_id)
        REFERENCES Products (product_id)
);

INSERT INTO customers VALUES
(1, 'Alice', 'New York', '2022-01-10'),
(2, 'Bob', 'Los Angeles', '2022-02-15'),
(3, 'Charlie', 'New York', '2022-03-12'),
(4, 'David', 'Chicago', '2022-01-20'),
(5, 'Eva', 'Los Angeles', '2022-04-01');

INSERT INTO orders VALUES
(101, 1, '2022-02-01', 120),
(102, 2, '2022-02-05', 80),
(103, 1, '2022-03-01', 150),
(104, 3, '2022-03-15', 200),
(105, 2, '2022-04-01', 50),
(106, 3, '2022-04-10', 300);

INSERT INTO products VALUES
(1, 'Laptop', 'Electronics', 800),
(2, 'Phone', 'Electronics', 500),
(3, 'Tablet', 'Electronics', 300),
(4, 'Desk', 'Furniture', 200),
(5, 'Chair', 'Furniture', 100);

INSERT INTO order_items VALUES
(101, 1, 1),
(101, 2, 1),
(102, 2, 1),
(103, 1, 1),
(104, 3, 2),
(105, 4, 1),
(106, 1, 2);


SELECT 
    *
FROM
    order_items;
SELECT 
    *
FROM
    customers;
SELECT 
    *
FROM
    orders;
SELECT 
    *
FROM
    products;





/* =========================================================
   BASIC & INTERMEDIATE SQL QUESTIONS (1-12)
   ========================================================= */

SELECT 
    COUNT(*) AS Unique_customers
FROM
    customers;

-- Q2 . Find customers from newyork.
SELECT 
    customer_name AS customers
FROM
    customers
WHERE
    city = 'New York';

-- Q3. Total orders per customer
SELECT 
    customer_id, COUNT(*) AS total_order
FROM
    orders
GROUP BY customer_id;

-- Q4. Total Revenue
SELECT 
    SUM(amount)
FROM
    orders;

-- Q5. Average Order values
SELECT 
    AVG(amount)
FROM
    orders;

-- Q6. Customers who signed up in 2022
SELECT 
    *
FROM
    customers
WHERE
    sign_up_date LIKE '%2022%';

-- Q7. Customers with more than one order
SELECT 
    customer_id, COUNT(*)
FROM
    orders
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Q8. Customer name with total spending
SELECT 
    c.customer_name AS Name, SUM(o.amount) AS Total_spending
FROM
    customers c
        JOIN
    orders o ON c.customer_id = o.customer_id
GROUP BY Name;

-- Q9. Customers with no orders
SELECT 
    c.customer_id, c.customer_name
FROM
    customers c
        LEFT JOIN
    orders o ON c.customer_id = o.customer_id
WHERE
    o.order_id IS NULL;

-- Q10. order placed in march 2022
SELECT 
    *
FROM
    orders
WHERE
    order_date LIKE '2022-04%';

--  Q11. Highest order amount
SELECT 
    MAX(amount)
FROM
    orders;

-- Q12. Total quantity sold per product
SELECT 
    product_id, SUM(quantity) AS Total_Quantity
FROM
    order_items
GROUP BY product_id;

-- text
/* =========================================================
   ADVANCED SQL QUESTIONS (13-20)
   ========================================================= */

-- Q13. Rank customers by total spending
select o.customer_id as Customer_id,sum(o.amount) as Total_Spending,
c.customer_name as Customer_Name,
rank() over(order by sum(o.amount) desc) as spending_Rank
from customers c
join orders o
on o.customer_id = c.customer_id
group by o.customer_id;	

-- Q14. Top 2 highest-spending customers

select * from (
select o.customer_id as Customer_id,sum(o.amount) as Total_Spending,
c.customer_name as Customer_Name,
rank() over(order by sum(o.amount) desc) as spending_Rank
from customers c
join orders o
on o.customer_id = c.customer_id
group by o.customer_id
) as ranked
where spending_Rank >=2;



-- Q15. Running total of revenue by date
select order_date,
sum(amount) as Revenue,
sum(sum(amount)) over(order by order_date) as running_total
from orders
group by order_date;

-- Q16. Category-wise revenue
SELECT 
    p.category AS category,
    SUM(oi.quantity * o.amount) AS revenue
FROM
    products p
        JOIN
    order_items oi ON p.product_id = oi.product_id
        JOIN
    orders o ON oi.order_id = o.order_id
GROUP BY p.category;

-- Q17. Most sold product (by quantity)
SELECT 
    p.product_name AS product, SUM(oi.quantity) AS Quantity
FROM
    products p
        JOIN
    order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_name
ORDER BY Quantity DESC
LIMIT 1;




# Q18. Customers spending above average


WITH customer_spending AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        SUM(o.amount) AS total_spending
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY 
        c.customer_id, 
        c.customer_name
)

SELECT 
    customer_id,
    customer_name,
    total_spending
FROM customer_spending
WHERE total_spending > (
    SELECT AVG(total_spending)
    FROM customer_spending
);

-- alternative

select * from 
(
 SELECT 
        c.customer_id,
        c.customer_name,
        SUM(o.amount) AS total_spending
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY 
        c.customer_id, 
        c.customer_name) t
	where total_spending > (select avg(amount) from orders);

-- Q19. Customer spending classification (CASE)
SELECT 
    c.customer_id,
    c.customer_name,
    SUM(o.amount) AS Total_spendings,
    (CASE
        WHEN SUM(o.amount) >= 500 THEN 'High'
        WHEN SUM(o.amount) > 250 THEN 'Medium'
        ELSE 'Low'
    END) AS Classifications
FROM
    customers c
        JOIN
    orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id , c.customer_name;

-- Q20. Customers who purchased Electronics
SELECT DISTINCT
    c.customer_name, p.category
FROM
    customers c
        JOIN
    orders o ON c.customer_id = o.customer_id
        JOIN
    order_items oi ON o.order_id = oi.order_id
        JOIN
    products p ON oi.product_id = p.product_id
WHERE
    p.category = 'Furniture'; 




