use ss13;

-- 1.
create table accounts(
	account_id int primary key auto_increment,
    account_name varchar(50),
    balance decimal(15,2)
);
-- 2
INSERT INTO accounts (account_name, balance) VALUES 

('Nguyễn Văn An', 1000.00),

('Trần Thị Bảy', 500.00);

-- 3
DELIMITER &&

create procedure transfer_money(
	IN from_account INT,
    IN to_account INT, 
    IN amount decimal(10,2)
)

begin 
	declare sender_balance decimal(10,2); 
    
    start transaction;
    if sender_balance >= amount then
		update accounts 
        set balance = balance - mount
        where account_id = from_account;
        
        update accounts
        set balance = balance + amount
        where account_id = to_account;
        
		commit;
	else 
		rollback;
	end if;
end &&

DELIMITER &&;
-- 4
call transfer_money(1,2,20);
