USE customer_behavior;
GO

SELECT * FROM customer;
GO

-- Q1. Total revenue by gender
SELECT 
    gender, 
    SUM(purchase_amount) AS revenue
FROM customer
GROUP BY gender;
GO

-- Q2. Customers who used discount and spent above average
SELECT 
    customer_id, 
    purchase_amount
FROM customer
WHERE discount_applied = 'Yes'
  AND purchase_amount >= (
        SELECT AVG(purchase_amount) 
        FROM customer
      );
GO

-- Q3. Top 5 products with highest average review rating
SELECT TOP 5
    item_purchased,
    ROUND(AVG(CAST(review_rating AS DECIMAL(3,2))), 2) AS Average_Product_Rating
FROM customer
GROUP BY item_purchased
ORDER BY AVG(CAST(review_rating AS DECIMAL(3,2))) DESC;
GO

-- Q4. Average purchase amount by shipping type
SELECT 
    shipping_type, 
    ROUND(AVG(purchase_amount), 2) AS avg_purchase
FROM customer
WHERE shipping_type IN ('Standard', 'Express')
GROUP BY shipping_type;
GO

-- Q5. Subscriber vs Non-subscriber spending comparison
SELECT 
    subscription_status,
    COUNT(customer_id) AS total_customers,
    ROUND(AVG(purchase_amount), 2) AS avg_spend,
    ROUND(SUM(purchase_amount), 2) AS total_revenue
FROM customer
GROUP BY subscription_status
ORDER BY total_revenue DESC, avg_spend DESC;
GO

-- Q6. Products with highest discount usage percentage
SELECT 
    item_purchased,
    ROUND(
        100.0 * SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS discount_rate
FROM customer
GROUP BY item_purchased
ORDER BY discount_rate DESC;
GO

-- Q7. Customer segmentation
WITH customer_type AS (
    SELECT 
        customer_id,
        previous_purchases,
        CASE 
            WHEN previous_purchases = 1 THEN 'New'
            WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
            ELSE 'Loyal'
        END AS customer_segment
    FROM customer
)
SELECT 
    customer_segment,
    COUNT(*) AS Number_of_Customers
FROM customer_type
GROUP BY customer_segment;
GO

-- Q8. Top 3 products in each category
WITH item_counts AS (
    SELECT 
        category,
        item_purchased,
        COUNT(customer_id) AS total_orders,
        ROW_NUMBER() OVER (
            PARTITION BY category 
            ORDER BY COUNT(customer_id) DESC
        ) AS item_rank
    FROM customer
    GROUP BY category, item_purchased
)
SELECT 
    item_rank,
    category,
    item_purchased,
    total_orders
FROM item_counts
WHERE item_rank <= 3;
GO

-- Q9. Subscription status of repeat buyers
SELECT 
    subscription_status,
    COUNT(customer_id) AS repeat_buyers
FROM customer
WHERE previous_purchases > 5
GROUP BY subscription_status;
GO

-- Q10. Revenue by age group
SELECT 
    age_group,
    SUM(purchase_amount) AS to_
