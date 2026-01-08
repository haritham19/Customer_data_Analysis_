select * from customer_shopping_behavuiour_analysis
--Total revenue created by male vs female--
SELECT gender,SUM(purchase_amount) AS Revenue
FROM customer_shopping_behavuiour_analysis
GROUP BY gender
---customer used discount but still spent more than the average purchase amount--
SELECT customer_id,purchase_amount
FROM customer_shopping_behavuiour_analysis
WHERE discount_applied='Yes' AND purchase_amount>=(SELECT AVG(purchase_amount) FROM customer_shopping_behavuiour_analysis)
--top 5 products with the highest average review rating--
SELECT TOP 5
item_purchased,ROUND(AVG(review_rating),2) as Average_product_rating
FROM customer_shopping_behavuiour_analysis
GROUP BY item_purchased
ORDER BY AVG(review_rating) DESC
--compare the average purchase amounts between standard and express shipping--
SELECT shipping_type,ROUND(AVG(purchase_amount),2) AS avg_amount
FROM customer_shopping_behavuiour_analysis
WHERE shipping_type in('Standard','Express')
GROUP BY shipping_type
--Average spent between the subscribed and un-subscribed customer--
SELECT subscription_status,
       COUNT(customer_id) AS total_customers,
       ROUND(AVG(purchase_amount),2) AS avg_spend,
       ROUND(SUM(purchase_amount),2) AS total_revenue
FROM customer_shopping_behavuiour_analysis
GROUP BY subscription_status
ORDER BY total_revenue,avg_spend DESC;
--Which 5 products have the highest percentage of purchases with discounts applied--
SELECT TOP 5
item_purchased,
       (ROUND(100.0 * SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END)/COUNT(*),2)) AS discount_rate
FROM customer_shopping_behavuiour_analysis
GROUP BY item_purchased
ORDER BY discount_rate DESC
--Segment customers into New, Returning, and Loyal based on their total 
-- number of previous purchases, and show the count of each segment. 
with customer_type as (
SELECT customer_id, previous_purchases,
CASE 
    WHEN previous_purchases = 1 THEN 'New'
    WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
    ELSE 'Loyal'
    END AS customer_segment
FROM customer_shopping_behavuiour_analysis)

select customer_segment,count(*) AS "Number of Customers" 
from customer_type 
group by customer_segment;
-- What are the top 3 most purchased products within each category? 
WITH item_counts AS (
    SELECT category,
           item_purchased,
           COUNT(customer_id) AS total_orders,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY COUNT(customer_id) DESC) AS item_rank
    FROM customer_shopping_behavuiour_analysis
    GROUP BY category, item_purchased
)
SELECT item_rank,category, item_purchased, total_orders
FROM item_counts
WHERE item_rank <=3;
 --Are customers who are repeat buyers (more than 5 previous purchases) also likely to subscribe--
SELECT subscription_status,
       COUNT(customer_id) AS repeat_buyers
FROM customer_shopping_behavuiour_analysis
WHERE previous_purchases > 5
GROUP BY subscription_status;
--revenue contribution of each age group--
SELECT 
    age_group,
    SUM(purchase_amount) AS total_revenue
FROM customer_shopping_behavuiour_analysis
GROUP BY age_group
ORDER BY total_revenue desc;

 

