create database dinner;
use dinner;

CREATE TABLE sales (
    customer_id CHAR(1),
    order_date DATE,
    product_id INT
);
INSERT INTO sales (customer_id, order_date, product_id) VALUES
('A', '2021-01-01', 1),
('A', '2021-01-01', 2),
('A', '2021-01-07', 2),
('A', '2021-01-10', 3),
('A', '2021-01-11', 3),
('A', '2021-01-11', 3),
('B', '2021-01-01', 2),
('B', '2021-01-02', 2),
('B', '2021-01-04', 1),
('B', '2021-01-11', 1),
('B', '2021-01-16', 3),
('B', '2021-02-01', 3),
('C', '2021-01-01', 3),
('C', '2021-01-01', 3),
('C', '2021-01-07', 3);

CREATE TABLE menu (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(20),
    price INT
);
INSERT INTO menu (product_id, product_name, price) VALUES
(1, 'sushi', 10),
(2, 'curry', 15),
(3, 'ramen', 12);

CREATE TABLE members (
    customer_id CHAR(1) PRIMARY KEY,
    join_date DATE
);

INSERT INTO members (customer_id, join_date) VALUES
('A', '2021-01-07'),
('B', '2021-01-09');

select * from sales;
select * from members;
select * from menu;

-- 1. What is the total amount each customer spent at the restaurant? 
select s.customer_id as Customer ,sum(m.price) as Total_Amount
from sales s 
join menu m 
on s.product_id = m.product_id
group by s.customer_id ;

-- 2. How many days has each customer visited the restaurant?
SELECT 
    customer_id AS Customer, 
    COUNT(DISTINCT order_date) AS Total_no_of_Visit
FROM sales
GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?
select s.customer_id as Customer,
m.product_name as First_item
from sales s
join menu m 
on s.product_id=m.product_id
where s.order_date = (select
min(s.order_date) from sales s
WHERE customer_id = s.customer_id
);

	-- 4. What is the most purchased item on the menu and how many times was it purchased by all 
	-- customers?
	select m.product_name as Item, count(s.product_id) as No_of_times_Item_Purchased
	from menu m 
	join sales s 
	on m.product_id = s.product_id
	group by Item
	order by No_of_times_Item_Purchased desc
	limit 1;
    
    WITH RankedItems AS (
    SELECT 
        m.product_name AS Item,
        COUNT(s.product_id) AS No_of_times_Item_Purchased,
        DENSE_RANK() OVER (ORDER BY COUNT(s.product_id) DESC) as rnk
    FROM menu m
    JOIN sales s 
        ON m.product_id = s.product_id
    GROUP BY m.product_name
)
SELECT 
    Item, 
    No_of_times_Item_Purchased
FROM RankedItems
WHERE rnk = 1;

-- 5. Which item was the most popular for each customer?
SELECT 
    s.customer_id AS Customer,
    m.product_name AS Most_Popular_Item,
    COUNT(s.product_id) AS Times_Purchased
FROM sales s
JOIN menu m 
    ON s.product_id = m.product_id
GROUP BY s.customer_id, m.product_name
HAVING COUNT(s.product_id) = (
    -- Subquery to find the highest order count for the current customer
    SELECT MAX(item_count)
    FROM (
        SELECT COUNT(product_id) AS item_count
        FROM sales
        WHERE customer_id = s.customer_id
        GROUP BY product_id
    ) AS sub
)
ORDER BY Customer;

-- 6. Which item was purchased first by the customer after they became a member? 
select * from sales;
select * from members;
select * from menu;
select s.customer_id as Customer,
m.product_name as First_Item_After_Member
from sales s 
join menu m 
on s.product_id=m.product_id
join members mb
on s.customer_id = mb.customer_id
where s.order_date>=mb.join_date
and s.order_date = (
select min(s2.order_date)
from sales s2
where s2.customer_id=s.customer_id
and s2.order_date>=mb.join_date
);

-- 7. Which item was purchased just before the customer became a member? \
select s.customer_id as Customer,m.product_name as Last_Item_Before_Member
from sales s
join menu m 
on s.product_id = m.product_id
join members mb
on s.customer_id = mb.customer_id
where s.order_date<mb.join_date
and s.order_date=(
select max(s2.order_date)
from sales s2
where s2.customer_id = s.customer_id
and s2.order_date < mb.join_date
);

-- 8. What is the total items and amount spent for each member before they became a member? 
SELECT 
    s.customer_id AS Customer,
    COUNT(s.product_id) AS Total_Items,
    SUM(m.price) AS Total_Amount
FROM
    sales s
        JOIN
    menu m ON s.product_id = m.product_id
        JOIN
    members mb ON s.customer_id = mb.customer_id
WHERE
    s.order_date < mb.join_date
GROUP BY Customer
ORDER BY Total_Amount;

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT 
    s.customer_id AS Customer,
    SUM(
        CASE 
            WHEN m.product_name = 'sushi' THEN m.price * 20
            ELSE m.price * 10
        END
    ) AS Points
FROM sales s
JOIN menu m
    ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY Customer;    

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on 
-- all items, not just sushi - how many points do customer A and B have at the end of January?  

SELECT 
    s.customer_id AS Customer,
    CONCAT(
        SUM(
            CASE 
                -- 1. First week after joining (includes join date = 7 days total)
                WHEN s.order_date >= mb.join_date 
                 AND s.order_date < mb.join_date + 7 THEN m.price * 20
                
                -- 2. Sushi outside the first week gets 2x points
                WHEN m.product_name = 'sushi' THEN m.price * 20
                
                -- 3. Everything else gets standard points
                ELSE m.price * 10
            END
        ),
        ' points'
    ) AS Total_Points
FROM sales s
JOIN menu m 
    ON s.product_id = m.product_id
JOIN members mb 
    ON s.customer_id = mb.customer_id
WHERE s.order_date <= '2021-01-31'
GROUP BY s.customer_id
ORDER BY Customer;