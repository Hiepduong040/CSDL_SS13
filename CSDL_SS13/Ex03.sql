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

-- 2
DELIMITER &&

create procedure transfer_salary(
    in p_emp_id int   
)
begin 
    declare company_balance decimal(15,2);
    declare employee_salary decimal(10,2);
    declare bank_error boolean default false;   
    
    start transaction;
 
    select balance into company_balance
    from company_funds
    where fund_id = 1; 
 
    select salary into employee_salary
    from employees
    where emp_id = p_emp_id;
 
    if company_balance >= employee_salary then 
        update company_funds
        set balance = balance - employee_salary
        where fund_id = 1;
 
        insert into payroll (emp_id, salary, pay_date)
        values (p_emp_id, employee_salary, curdate());
 
        if bank_error then
            rollback;
        else
            commit;
        end if;
    else 
        rollback;
    end if;

end &&

DELIMITER ;


-- 3
call transfer_salary(1);
select * from company_funds; 
select * from payroll; 

