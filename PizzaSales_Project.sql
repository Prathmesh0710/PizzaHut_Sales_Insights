use pizza_project;
select * from order_details;
select * from orders;
select * from pizza_types;
select * from pizzas;

-- Retrieve the total number of orders placed.
select count(distinct order_id) as "Total_Orders" from orders;

-- Calculate the total revenue generated from pizza sales
 
 select cast(sum(order_details.quantity * pizzas.price) as decimal(8,2) ) as "Total_Revenue"
 	from  order_details
 		join pizzas
 		on order_details.pizza_id = pizzas.pizza_id;
 
 -- Identify the highest-priced pizza.
 select pizza_types.name as 'Top_pizza_Name'
 	from pizzas
 	join 
	 pizza_types
 	on pizza_types.pizza_type_id =pizzas.pizza_type_id
 order by pizzas.price desc
 limit 1;
 
 -- Using windows function Rank()
 select Top_Pizza_Name
 from
	(
		select pizza_types.name as Top_Pizza_Name,
        rank() over(Order by pizzas.price desc) as rnk
        from pizzas
		join pizza_types
		on pizza_types.pizza_type_id =pizzas.pizza_type_id
    ) ranked_pizza
    where rnk =1;
    

-- Identify the most common pizza size ordered.

 
 select pizzas.size, count(distinct order_id) as 'No of Orders', sum(quantity) as 'Total Quantity Ordered' 
	from order_details
		join pizzas on pizzas.pizza_id = order_details.pizza_id
	group by pizzas.size
	order by count(distinct order_id) desc

-- List the top 5 most ordered pizza types along with their quantities.
 
 select pizza_types.name as 'Pizza_Name', sum(order_details.quantity) as 'Quantity'
from
	pizza_types
	join
		pizzas
	join 
		order_details on  pizza_types.pizza_type_id = pizzas.pizza_type_id
         and  pizzas.pizza_id = order_details.pizza_id
    group by   pizza_types.name
	order by sum(order_details.quantity) desc
	limit 5;
  
  -- -- -----------------------------------------------------------
 
 -- Join the necessary tables to find the total quantity of each pizza category ordered.
   
 select pizza_types.category as 'Pizzas_Category', 
 sum(order_details.quantity) as 'Quantity'
 from pizza_types
 join 
	pizzas
    on pizza_types.pizza_type_id= pizzas.pizza_type_id
 join
	order_details
    on pizzas.pizza_id=order_details.pizza_id
  group by pizza_types.category 
  order by sum(order_details.quantity) desc;
  
  ---------------------------------------------
  
  -- Determine the distribution of orders by hour of the day.
  
  select 
	hour(time) as 'Order_hour',  count(order_id) as 'Order_Count'
  from 
	orders
  group by Order_hour
  order by Order_hour;
  
  
  --------------------------------------------------------
  
  -- Join relevant tables to find the category-wise distribution of pizzas.
  
  select pizza_types.category as 'Category', count(pizzas.pizza_id ) as 'pizza_Count'
  from
	pizza_types
		join
	Pizzas 
		on pizza_types.pizza_type_id = pizzas.pizza_type_id
  group by 
	pizza_types.category;
    
 -----------------------------------------------------
 
 
-- the number of of orders with quantity per day
    select orders.date as 'Order_Date',
    -- sum(order_details.quantity ) as 'Quantity_order', 
    count( orders.order_id) as 'Order_Count'
    from 
    orders
		join 
		order_details
			on orders.order_id = order_details.order_id
    group by orders.date
    order by orders.date;
-------------------------------------------------------------

-- Group the orders by date and calculate the average number of pizzas ordered per day.      
  
    select date as 'date',
        cast(avg(TotalPizza_Ordered) as decimal(6,2)) Avg_pizza_orders_perday
        from (
			select 
				orders.date as 'date',
					sum(order_details.quantity) as 'TotalPizza_Ordered'
				from 
					order_details
						join
					orders
						on order_details.order_id = orders.order_id
			group by orders.date					
        ) AS Daily_Pizzas
        group by date
        order by date;
        
        -----------------------------------------------------
        -- Determine the top 3 most ordered pizza types based on revenue.
        select cast(sum(order_details.quantity * pizzas.price) as decimal(8,2) ) as "Total_Revenue",
        pizzas.pizza_type_id as 'Pizza_Type'
        	from 
			order_details
				join 
			pizzas
				on order_details.pizza_id = pizzas.pizza_id
				join
			pizza_types
                on pizzas.pizza_type_id = pizza_types.pizza_type_id
		group by pizzas.pizza_type_id
		order by Total_Revenue desc
		limit 3;
        
        --------------------------------------------------------------
        
        -- Calculate the percentage contribution of each pizza type to total revenue.
            
		select pizza_types.category as 'Category',
        cast(sum(order_details.quantity * pizzas.price) as decimal(8,2) ) as "Category_Revenue",
        cast(
			(sum(order_details.quantity * pizzas.price)/ 
			( select sum(order_details.quantity * pizzas.price) from order_details
				join
					pizzas on order_details.pizza_id = pizzas.pizza_id)) *100 
				as decimal(5,2))
				as 'percentage_contribution'         
         from 
				order_details
			join
				pizzas 
				on order_details.pizza_id = pizzas.pizza_id
			join 
				pizza_types
				on pizzas.pizza_type_id = pizza_types.pizza_type_id
         group by 
				pizza_types.category
         order by        
				percentage_contribution desc;
            
       --------------------------------------------------------
       
-- Analyze the cumulative revenue generated over time.
        
           
SELECT 
    orders.date, 
    CAST(SUM(order_details.quantity * pizzas.price) AS DECIMAL(10,2)) AS Daily_Revenue, 
    CAST(
        SUM(SUM(order_details.quantity * pizzas.price)) OVER (ORDER BY orders.date) 
        AS DECIMAL(10,2)
    ) AS Cumulative_Revenue
FROM 
    orders
JOIN 
    order_details ON orders.order_id = order_details.order_id
JOIN 
    pizzas ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 
    orders.date
ORDER BY 
    orders.date;

-------------------------------------------------------------

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select 
	category, name, round(revenue,2) as Revenue, Rnk
from (
	select category, name, revenue, rank() over (partition by category order by revenue desc) as rnk 
	from (
		select 
			pizza_types.category, pizza_types.name, sum(order_details.quantity*pizzas.price) as revenue
			from 
				pizza_types 
					join 
				pizzas 
					join 
				order_details on pizza_types.pizza_type_id=pizzas.pizza_type_id and pizzas.pizza_id=order_details.pizza_id
			group by pizza_types.category, pizza_types.name) as a)as b
where rnk < 4;



  
  
