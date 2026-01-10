create database OnlineBookStore;
use onlinebookstore;

create table Books(
Book_id serial primary key,
Title varchar(100),
Author varchar(100),
Genre varchar(50),
Published_Year int,
Price numeric(10,2),
Stock int
);


create table Customers(
Customer_id serial primary key,
Name varchar(100),
Email varchar(100),
Phome varchar(15),
City varchar (50),
Country varchar(150)
);

create table Orders(
Order_id serial primary key,
Customer_id int references Customers(Customer_id),
Book_id int references Books(Book_id),
Order_Date date,
Quantity int,
Total_Amount numeric (10,2)
);

select * from Books;
select * from Customers;

select * from Orders;


describe books;
describe customers;
describe orders;


/*drop table books1;
drop table Orders;
show tables;*/

/*copy Books(Book_id, Title, Author, Genre, Published_Year, Price, Stock)
from 'C:/Users/Bhavika/OneDrive/Desktop/Books1csv.csv'
csv header;*/


/*LOAD DATA INFILE "C:/sql_project_online_book_store/Books1.csv"
INTO TABLE Books
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Book_id, Title, Author, Genre, Published_Year, Price, Stock);*/
describe customers;
describe orders;
describe books;

ALTER TABLE Orders
ADD CONSTRAINT fk_customer
FOREIGN KEY (Customer_ID)
REFERENCES Customers(Customer_id);

ALTER TABLE Orders
ADD CONSTRAINT fk_book
FOREIGN KEY (Book_ID)
REFERENCES Books(Book_id);


ALTER TABLE Orders
MODIFY Customer_ID BIGINT(20) UNSIGNED;
ALTER TABLE Orders
ADD CONSTRAINT fk_customer
FOREIGN KEY (Customer_ID)
REFERENCES Customers(Customer_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE Orders
MODIFY Book_ID BIGINT(20) UNSIGNED;

ALTER TABLE Orders
ADD CONSTRAINT fk_book
FOREIGN KEY (Book_ID)
REFERENCES Books(Book_id)
ON DELETE CASCADE
ON UPDATE CASCADE;




-- 1. Retrive all books in the "Fiction" genre.
select * from books where genre="fiction";

-- 2. Find books published after the year 1950.
select * from books where Published_Year>1950;

-- 3. List all customers from the Canada.
select * from customers where country= 'canada';

-- 4. Show orders placed in November 2023.(Wrong)
DESCRIBE orders;
alter table orders modify Order_date date;
select * from orders where Order_date between '01-11-2023' and '30-11-2023';
select * from orders where Order_date >= "01-11-2023" and Order_date<="30-11-2023";

-- 5. Retrive the total stock of books avaliable.
select book_id, title,sum(stock) as total_stock from books group by book_id, title ;

-- 6. Find the deatils of the most expensive book;
select * from books order by price desc limit 1;

-- 7. show all customers who orders more than 1 quantity of a book.
select * from orders where quantity>1;

-- 8. Retrive all orders where the toal amount exceeds $20;
select * from orders where Total_Amount > 20;

-- 9. List all genres available in the books table;
select genre from books group by genre;
select distinct genre from books;

-- 10. find the book with the lowest stock;
select * from books order by stock limit 1;

-- 11. Calculate the total revenue generated from all orders;
select sum(total_amount) as revenue from orders;

-- Advance Question
-- 1. Retrive the total number of books sold for each genre;
select b.genre, sum(o.quantity) as total_books_sold
from orders o 
join books b on o.book_id=b.book_id
group by b.genre;

-- 2.Find the average price of books in the "Fantasy" genre;
select avg(price) as average
from books where genre="Fantasy";

-- 3. List customers who have placed at least 2 orders
select c.customer_id,c.Name, count(o.order_id) as order_count 
from orders o join customers c 
on o.customer_id=c.customer_id
group by o.customer_id, c.name
having count(order_id)>=2;


-- 4. Find the most frequently ordered book;(added)
select o.book_id, b.title, count(o.order_id) as order_count
from orders o
join books b on o.book_id=b.book_id
group by o.book_id, b.title
order by order_count desc limit 1;


-- 5. Show the top 3 most expensive books of "Fantasy" Genre;
select * from books
where genre="Fantasy" order by price desc  limit 3;

-- 6. Retrive the total quantity of books sold by each author;
select b.author, sum(o.quantity) as total_books_sold
from orders o join books b on o.book_id=b.book_id
group by b.author;


-- 7. List the cities where customers who spent over $200 are located;
select distinct c.city, o.total_amount
from customers c join orders o on c.customer_id=o.customer_id
 where o.total_amount > 200;
 
 -- least spending customers for giving offers and discount
 SELECT c.customer_id, c.name, c.city, 
 SUM(o.total_amount) AS total_spent
FROM customers c JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name, c.city
ORDER BY total_spent ASC LIMIT 5;


-- 8. Find the customer who spent the most on orders; added
select c.name,sum(o.total_amount) as total_spent
from customers c join orders o on c.customer_id=o.customer_id
group by c.name
order by total_spent desc limit 1 ;

-- 9 calculate the stock remaining after fulfilling all orders; added 
select b.book_id, b.title, b.stock, coalesce(sum(o.quantity),0) as order_quantity,
b.stock - coalesce(sum(o.quantity),0) as remaining_quantity
from books b 
left join orders o  on b.book_id = o.book_id group by b.book_id order by b.book_id;



-- WINDOWS FUNCTIONS
-- To assign a unique sequential number to each order based on order_id.
SELECT order_id, customer_id, book_id, total_amount,
 row_number() over (order by order_id) as row_num from orders;
   

-- To rank customers  WITH GAPS in ranking when amounts are equal.                                          
SELECT customer_id, sum(total_amount) as total_spent,
rank() over ( order by sum(total_amount) desc) as rank_no from orders group by customer_id;
    
    
-- To rank books without gaps even if prices are same.
SELECT book_id, title, price, 
dense_rank() over ( order by price desc ) as price_rank from books;
 
 
-- To calculate running total of sales across orders.
SELECT order_id, order_date, total_amount, 
sum(total_amount) over ( order by order_id) as running_total from orders;
  

-- subsquery
-- for Detect low-performing inventory.
select book_id, title from books where book_id not in
	(select distinct book_id from orders);

-- 5. Customers Who Spent the Least (For Discounts & Offers)
-- Purpose: Target customers eligible for discounts.
select c.customer_id, c.name, o.total_amount
from customers c
join orders o on c.customer_id = o.customer_id
where o.total_amount =
	(select MIN(total_amount) from orders);
    
    

-- views
-- Summarizes total quantity sold and total revenue per book.
create view vw_book_sales_summary as
select b.Book_ID, b.Title,
    SUM(o.Quantity) as Total_Quantity_Sold,
    SUM(o.Total_Amount) as Total_Revenue
from Books b
join Orders o
on b.Book_ID = o.Book_ID
group by b.Book_ID, b.Title;

select * from vw_book_sales_summary;

