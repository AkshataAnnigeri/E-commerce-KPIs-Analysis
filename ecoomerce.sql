use ecommerce;

select * from (select Year(`order date`) as order_year, Segment, avg(`profit margin`) as avg_profit_margin
from ecommerce
group by order_year, Segment) as avg_profit
where order_year>=2020 & order_year<=2023;

select Country, State, City, avg(`profit margin`) as avg_profit_margin
from ecommerce
group by Country, State, City;

select * from (select Year(`order date`) as order_year, Market, avg(`profit margin`) as avg_profit_margin
from ecommerce
group by order_year, Market) as avg_profit
where order_year>=2020 & order_year<=2023;

/* Best selling product by sales volume */

with cte_bestselling_volume as
(select Year(`Order Date`) as order_Year,Product,Category,Subcategory,sum(Quantity) as sales_volume,
		row_number() over (partition by Year(`Order Date`) order by sum(Quantity) desc ) as rank_
		from ecommerce
		group by Year(`Order Date`), Product, Category,Subcategory
		order by sum(Quantity) desc) 
select order_Year,Product, Category,Subcategory, sales_volume
from cte_bestselling_volume
where rank_<=5
order by order_Year, sales_volume;

/*profitability*/

with cte_bestselling_profit as
(select Year(`Order Date`) as order_Year,Product,Category,Subcategory,sum(Profit) as profitability,
		row_number() over (partition by Year(`Order Date`) order by sum(Profit) desc ) as rank_
		from ecommerce
		group by Year(`Order Date`), Product, Category,Subcategory
		) 
select order_Year,Product, Category,Subcategory, profitability
from cte_bestselling_profit
where rank_<=5
order by order_Year, profitability desc;

with cte_bestselling_sales as
(select Year(`Order Date`) as order_Year,Product,Category,Subcategory,sum(Sales) as revenue,
		row_number() over (partition by Year(`Order Date`) order by sum(Sales) desc ) as rank_
		from ecommerce
		group by Year(`Order Date`), Product, Category,Subcategory
		order by sum(Sales) desc) 
select order_Year,Product, Category,Subcategory, revenue
from cte_bestselling_sales
where rank_<=5
order by order_Year, revenue desc;

/*YoYrevenue*/

with cte as (select year(`Order Date`) as order_year,monthname(`Order Date`) as order_month, Product,Category,Subcategory, sum(Sales) as total_sales
from ecommerce
group by  year(`Order Date`),MonthNAME(`Order Date`),Category,Subcategory,Product
),

YoY as (select order_year,order_month, Product,Category,Subcategory, total_sales,
lag(total_sales,1) over (partition by Category,Subcategory,Product order by order_year,order_month) as previous_sales,
((total_sales - lag(total_sales,1) over (partition by Category,Subcategory,Product order by order_year,order_month))/nullif(lag(total_sales,1) over (partition by Category,Subcategory,Product order by order_year,order_month),0))*100 as YoY_Growth
from cte)
select * from YoY;

/*YoY profit margin*/

with cte_1 as (select year(`Order Date`) as order_year, Product,Category,Subcategory, avg(`profit margin`) as avg_profit_margin_growth
from ecommerce
group by  year(`Order Date`),Category,Subcategory,Product
),

YoY_1 as (select order_year, Product,Category,Subcategory, avg_profit_margin_growth,
lag(avg_profit_margin_growth,1) over (partition by Category,Subcategory,Product order by order_year) as previous_avg_profit_margin_growth,
((avg_profit_margin_growth - lag(avg_profit_margin_growth,1) over (partition by Category,Subcategory,Product order by order_year))/nullif(lag(avg_profit_margin_growth,1) over (partition by Category,Subcategory,Product order by order_year),0))*100 as YoY_avg_profit_margin_growth
from cte_1)
select * from YoY_1;

/*YoY Sales volume*/

with cte_2 as (select year(`Order Date`) as order_year, Product,Category,Subcategory, sum(Quantity) as total_products_sold
from ecommerce
group by  year(`Order Date`),Category,Subcategory,Product
),

YoY_2 as (select order_year, Product,Category,Subcategory,  total_products_sold,
lag( total_products_sold,1) over (partition by Category,Subcategory,Product order by order_year) as previous_total_products_sold,
(( total_products_sold - lag( total_products_sold,1) over (partition by Category,Subcategory,Product order by order_year))/nullif(lag( total_products_sold,1) over (partition by Category,Subcategory,Product order by order_year),0))*100 as YoY_total_products_soldGrowth
from cte_2)
select * from YoY_2;

/*YoY GROWTH % For Sales*/


select orderyearordermonth, Category, Subcategory, Product, sum(present_sales) as present_sales
from(select year(`Order Date`) as order_year, monthname(`Order Date`) as order_month, concat(year(`Order Date`) ,'-',monthname(`Order Date`))as orderyearordermonth, Category, Subcategory, Product, sum(Sales) as present_sales
from ecommerce
group by year(`Order Date`), monthname(`Order Date`),concat(year(`Order Date`) ,'-',monthname(`Order Date`)),Category, Subcategory, Product) as subgroup
group by orderyearordermonth,Category, Subcategory, Product;

select year(`Order Date`) as order_year, monthname(`Order Date`) as order_month, concat(year(`Order Date`) ,'-',monthname(`Order Date`))as orderyearordermonth, Category, Subcategory, Product, sum(Sales) as present_sales
from ecommerce
group by year(`Order Date`), monthname(`Order Date`),concat(year(`Order Date`) ,'-',monthname(`Order Date`)),Category, Subcategory, Product;

SELECT 
    YEAR(`Order Date`) AS order_year, 
    MONTHNAME(`Order Date`) AS order_month, 
    CONCAT(YEAR(`Order Date`), '-', MONTHNAME(`Order Date`)) AS orderyearordermonth, 
    Category, 
    Subcategory, 
    Product, 
    SUM(Sales) OVER (
        PARTITION BY Category, Subcategory, Product,MONTHNAME(`Order Date`),YEAR(`Order Date`) 
        ORDER BY MONTH(`Order Date`), YEAR(`Order Date`)
    ) AS present_sales
FROM ecommerce;

SELECT 
    YEAR(`Order Date`) AS order_year, 
    MONTHNAME(`Order Date`) AS order_month, 
    Category, 
    Subcategory, 
    Product, 
    SUM(Sales) AS total_sales
FROM ecommerce
GROUP BY 
    YEAR(`Order Date`), 
    monthname(`Order Date`), 
    Category, 
    Subcategory, 
    Product
ORDER BY 
    Category, 
    Subcategory, 
    Product, 
    MONTHNAME(`Order Date`), 
    YEAR(`Order Date`);
/*yoy final*/
with cte_presentsale as(
SELECT YEAR(`Order Date`) as order_year, monthname(`Order Date`) as order_month, month(`Order Date`) as order_month_num, sum(sales) as present_sales
from ecommerce
group by YEAR(`Order Date`), monthname(`Order Date`),month(`Order Date`)
)
select row_number() over (order by order_month_num, order_month, order_year ) as row_num,order_year, order_month, order_month_num, present_sales,
lag(present_sales,1) over (partition by order_month_num, order_month order by  order_month_num, order_month, order_year ) as previous_total_sales,
((present_sales-lag(present_sales,1) over (partition by order_month_num, order_month order by  order_month_num, order_month, order_year ) )/lag(present_sales,1) over (partition by order_month_num, order_month order by  order_month_num, order_month, order_year ) )*100 as YoY_GROWTH
from cte_presentsale;

/*YoY Profit margin*/
with cte_presentprofit as(
SELECT YEAR(`Order Date`) as order_year, monthname(`Order Date`) as order_month, month(`Order Date`) as order_month_num, avg(`profit margin`) as present_profit_margin
from ecommerce
group by YEAR(`Order Date`), monthname(`Order Date`),month(`Order Date`)
)
select row_number() over (order by order_month_num, order_month, order_year ) as row_num,order_year, order_month, order_month_num, present_profit_margin,
lag(present_profit_margin,1) over (partition by order_month_num, order_month order by  order_month_num, order_month, order_year ) as previous_profit_margin,
((present_profit_margin-lag(present_profit_margin,1) over (partition by order_month_num, order_month order by  order_month_num, order_month, order_year ) )/lag(present_profit_margin,1) over (partition by order_month_num, order_month order by  order_month_num, order_month, order_year ) )*100 as YoY_GROWTH_profit
from cte_presentprofit;

/*Discount average yoy trend*/

with cte_presentdiscount as(
SELECT YEAR(`Order Date`) as order_year, monthname(`Order Date`) as order_month, month(`Order Date`) as order_month_num, avg(Discount) as present_discount
from ecommerce
group by YEAR(`Order Date`), monthname(`Order Date`),month(`Order Date`)
)
select row_number() over (order by order_month_num, order_month, order_year ) as row_num,order_year, order_month, order_month_num, present_discount,
lag(present_discount,1) over (partition by order_month_num, order_month order by  order_month_num, order_month, order_year ) as previous_discount,
((present_discount-lag(present_discount,1) over (partition by order_month_num, order_month order by  order_month_num, order_month, order_year ) )/lag(present_discount,1) over (partition by order_month_num, order_month order by  order_month_num, order_month, order_year ) )*100 as YoY_discount
from cte_presentdiscount;

with cte_presentsale as(
SELECT YEAR(`Order Date`) as order_year, monthname(`Order Date`) as order_month, month(`Order Date`) as order_month_num,Category, Subcategory, Product, sum(sales) as present_sales
from ecommerce
group by YEAR(`Order Date`), monthname(`Order Date`),month(`Order Date`),Category, Subcategory, Product
)
select order_year, order_month, order_month_num,Category, Subcategory, Product, present_sales,
lag(present_sales,1) over (partition by Category, Subcategory, Product, order_month_num, order_month order by  order_month_num, order_month, order_year ) as previous_total_sales
from cte_presentsale;


SELECT 
    e.Market, 
    YEAR(e.`Order Date`) AS order_year, 
    e.Product, 
    e.Category, 
    e.Subcategory, 
    SUM(e.Quantity) AS sales_volume, 
    AVG(e.`profit margin`) AS average_profit_margin, 
    SUM(e.Sales) AS total_sales,
    market.market_revenue
FROM ecommerce AS e
JOIN (
    SELECT 
        c.Market, 
        YEAR(c.`Order Date`) AS order_year, 
        SUM(c.Sales) AS market_revenue
    FROM ecommerce AS c
    GROUP BY c.Market, YEAR(c.`Order Date`)
    ORDER BY YEAR(c.`Order Date`)
) AS market
ON e.Market = market.Market
AND YEAR(e.`Order Date`) = market.order_year
GROUP BY 
    e.Market, 
    YEAR(e.`Order Date`), 
    e.Product, 
    e.Category, 
    e.Subcategory
    market.market_revenue
ORDER BY 
    YEAR(e.`Order Date`);
    
select year(`Order Date`), month(`Order Date`),monthname(`Order Date`), sum(Quantity) as volume, sum(Sales) as revenue, avg(discount) as avg_discount, avg(`profit margin`) as avg_profit_margin
from ecommerce
group by year(`Order Date`), month(`Order Date`),monthname(`Order Date`)
order by year(`Order Date`), month(`Order Date`),monthname(`Order Date`);

select year(`Order Date`), month(`Order Date`),monthname(`Order Date`), sum(Quantity) as volume, sum(Sales) as revenue, avg(`profit margin`) as avg_profit_margin, sum(discount_amount) as total_discount_amount, sum(Profit)/sum(discount_amount) as profit_discount_ratio
from (select `Row ID`,`Order Date`,Sales,Quantity,Discount,Profit,`profit margin`,(Sales*Discount) as discount_amount
         from ecommerce) as dis_amt
group by year(`Order Date`), month(`Order Date`),monthname(`Order Date`)
order by year(`Order Date`), month(`Order Date`),monthname(`Order Date`);


 
