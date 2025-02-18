create database ss13;
use ss13;
CREATE TABLE company_funds (
    fund_id INT PRIMARY KEY AUTO_INCREMENT,
    balance DECIMAL(15,2) NOT NULL -- Số dư quỹ công ty
);

CREATE TABLE employees (
    emp_id INT PRIMARY KEY AUTO_INCREMENT,
    emp_name VARCHAR(50) NOT NULL,   -- Tên nhân viên
    salary DECIMAL(10,2) NOT NULL    -- Lương nhân viên
);

CREATE TABLE payroll (
    payroll_id INT PRIMARY KEY AUTO_INCREMENT,
    emp_id INT,                      -- ID nhân viên (FK)
    salary DECIMAL(10,2) NOT NULL,   -- Lương được nhận
    pay_date DATE NOT NULL,          -- Ngày nhận lương
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id)
);


INSERT INTO company_funds (balance) VALUES (50000.00);

INSERT INTO employees (emp_name, salary) VALUES
('Nguyễn Văn An', 5000.00),
('Trần Thị Bốn', 4000.00),
('Lê Văn Cường', 3500.00),
('Hoàng Thị Dung', 4500.00),
('Phạm Văn Em', 3800.00);
/*
	tạo bảng transaction_log 
    tạo procedure 
		input : employeeid, funid
        process :
			1 kiểm tra employeeid có tồn tại hay  không
				- sai --> ghi log bảng transaction_log và roll back lại
                - đúng -->kiểm tra số dư của công ty (company_fun) > salary(employee-->employeeid)
					- sai : ghi log transaction_log và rollback lại
                    - đúng :- trừ số dư của công ty trong bảng company_fun
							- ghi dữ liệu ra bảng payroll
                            - ghi log bảng transaction_log
                            - commit 
*/
-- 2
create table transaction_log (
	log_id int primary key auto_increment,
    log_message text not null,
    log_time timestamp default current_timestamp
) engine = 'MyISAM';
drop procedure sendsalaryemployee ; 
-- 3
alter table transaction_log
add column last_pay_date date;
-- 4
set autocommit = 0;
DELIMITER &&

create procedure transfer_salary(
    in employeeid int,
    in fundid int
)
begin
    declare company_balance decimal(10,2);
    declare employee_salary decimal(10,2);
    
    if not exists (select 1 from employees where emp_id = employeeid) or
       not exists (select 1 from company_funds where fund_id = fundid) then
        insert into transaction_log(log_message)
        values ('mã nhân viên hoặc mã quỹ không tồn tại');
        rollback;
    else
        select balance into company_balance from company_funds where fund_id = fundid;
        select salary into employee_salary from employees where emp_id = employeeid;
        
        if company_balance >= employee_salary then
            update company_funds
            set balance = balance - employee_salary
            where fund_id = fundid;
            
            insert into transaction_log(log_message)
            values ('thanh toán lương thành công');
            
            insert into payroll (emp_id, salary, pay_date) 
            values (employeeid, employee_salary, current_date);
            
            commit;
        else
            insert into transaction_log(log_message)
            values ('số dư tài khoản không đủ');
            rollback;
        end if;
    end if;
end &&

DELIMITER &&;


select * from company_funds;
select * from employees;
select * from transaction_log;
select * from payroll;

call transfer_salary(1,1);
