SELECT * FROM ecommerce.payments;

## Q # 1: How many payments were made in installments versus full payments?
SELECT 
    CASE
        WHEN payment_installments > 0 THEN 'installment'
        WHEN payment_installments = 0 THEN 'paid'
    END installment_status,
    COUNT(*) AS total_count
FROM
    payments
GROUP BY installment_status;

## Q # 2: What percentage of payments were made in installments?
SELECT 
    total_installment,
    ROUND(total_installment / total_count * 100, 3) percentage
FROM
    (SELECT 
        SUM(CASE
                WHEN payment_installments > 0 THEN '1'
                WHEN payment_installments = 0 THEN '0'
            END) total_installment,
            COUNT(*) total_count
    FROM
        payments) AS a;

select round((sum(case when payment_installments > 0 then '1' when payment_installments = 0 then '0' end) / count(*) * 100),3) paid_installement_perc from payments;
select count(*) from payments;


select * from payments where order_id = '0245631f7bd55dbee7c6b441629bba94';