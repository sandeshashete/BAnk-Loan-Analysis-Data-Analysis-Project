create database bank_loan_project ;
use bank_loan_project ;
create table finance_1
(id int not null primary key, 
member_id int,
loan_amnt int,
funded_amnt int,
funded_amt_inv decimal(15,2),
term varchar(30),
int_rate decimal(6,2),
installment decimal(8,2),
grade char(1),
sub_grade char(2),
emp_title varchar(100),
emp_length varchar(100),
home_ownership varchar(30),
annual_inc int,
verification_status varchar(50),
issue_d date,
loan_status varchar(50),
pymnt_plan varchar(5),
desc_ varchar(10000),
purpose varchar(100),
title varchar(200),
zip_code varchar(10),
addr_state varchar(5),
dti decimal(4,2));
select * from finance_1 ;
drop table finance_1;

load	data	infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Finance1.csv" 
into table finance_1
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows ;



show variables like 'secure-file-priv';

create table finance_2 
(id int not null primary key,
delinq_2yrs int,
earliest_cr_line date,
inq_last_6mths int,
mths_since_last_delinq  varchar(10) ,
mths_since_last_record varchar(10) ,
open_acc int,
pub_rec int,
revol_bal int,
revol_util decimal(20,12),
total_acc int,
initial_list_status varchar(10),
out_prncp int,
out_prncp_inv int,
total_pymnt decimal(18,10),
total_pymnt_inv decimal(18,10),
total_rec_prncp decimal(18,9),
total_rec_int decimal(15,8),
total_rec_late_fee decimal(25,15),
recoveries decimal(15,8),
collection_recovery_fee decimal(18,9),
last_pymnt_d varchar(20),
last_pymnt_amnt decimal(15,8),
next_pymnt_d varchar(20),
last_credit_pull_d  varchar(20)) ;

drop table finance_2 ;
select * from finance_2 ;
desc finance_2;


load	data	infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/finance2_clean.csv" 
into table finance_2
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows ;

#-------------------------KPI-1-----------Year wise loan amount Stats--------------
select * from finance_1;



select year_, loan_amount,  
concat(round(((loan_amount-PY)/PY)*100,2),'%') as percent_increase from
(select year(issue_d) as year_, sum(loan_amnt)as loan_amount, 
lag(sum(loan_amnt)) over (order by year(issue_d)) as PY
from finance_1
group by year_)qwe ;



#-------------KPI-2--------Grade and sub grade wise revol_bal---------------------
select * from finance_1 ;
select * from finance_2 ;




select grade, sub_grade, sum(revol_bal) as revolving_balance from finance_1 as a
join finance_2 as b
on a.id = b.id
group by grade, sub_grade
order by  grade,
revolving_balance desc  ;





#-------KPI-3------------------Total Payment for Verified Status Vs Total Payment for Non Verified Status-----------


select verification_status, total_payment, 
concat(round((total_payment/total)*100,2),'%') as percentage
from
(select
    a.verification_status,
    ROUND(SUM(b.total_pymnt),2) AS total_payment 
    
FROM
    finance_1 AS a
        JOIN
    finance_2 AS b ON a.id = b.id
WHERE
    a.verification_status = 'not verified'
        OR a.verification_status = 'verified'
GROUP BY a.verification_status)qw 
cross join 
(select round(sum(total_pymnt),2) as total from finance_2 b join finance_1 a on a.id =b.id
WHERE
    a.verification_status = 'not verified'
        OR a.verification_status = 'verified')asd
;

#---KPI-4----------State wise and month wise loan status--------------------------
select * from finance_1 ;
select * from finance_2 ;



SELECT 
    state, month_,count_of_loan_status
FROM
    (SELECT DISTINCT
        (addr_state) AS state,
            MONTHNAME(issue_d) month_,
            MONTH(issue_d) m1,
            COUNT(loan_status) AS count_of_loan_status
    FROM
        finance_1
    GROUP BY 1 , 2 , 3) qwe
ORDER BY  state, m1;


#-----------------KPI5--------------------Home ownership Vs last payment date stats



SELECT 
    YEAR(b.last_pymnt_d) AS year_,
     (a.home_ownership) as home_ownership,
    ROUND(SUM(b.last_pymnt_amnt), 2) AS total_last_payment
FROM
    finance_1 AS a
        JOIN
    finance_2 AS b ON a.id = b.id
WHERE
    YEAR(b.last_pymnt_d) IS NOT NULL
GROUP BY 1 , 2
ORDER BY year_, total_last_payment desc ;

