CREATE PROC get_cust_products_limit
(@cust_id int,@orderBy varchar(20),@xsc varchar(4),@startRecord int,@maxRecord int)
AS
BEGIN
WITH custprods as(
    select prod_code,sum(prod_share) as prod_share
    from asset_orders
    where cust_id=@cust_id
    group by prod_code
),a AS(
    select cp.prod_code,cp.prod_share,p.nav,p.accnav,cp.prod_share*p.nav as marketvalue,p.nav_date
    from custprods as cp,
        asset_product as p
    where cp.prod_code = p.prod_code
),b AS(
    select ROW_NUMBER() over(ORDER BY 
        CASE WHEN @orderBy='prod_code' or @orderBy='' or @orderBy is null THEN a.prod_code END,
        CASE WHEN @orderBy='prod_share' THEN a.prod_share END,
        CASE WHEN @orderBy='nav' THEN a.nav END,
        CASE WHEN @orderBy='marketvalue' THEN a.marketvalue END,
		CASE WHEN @orderBy='nav_date' THEN a.nav_date END
    ASC) as rownum,* from a
),c AS(
    select ROW_NUMBER() over(ORDER BY 
        CASE WHEN @xsc='asc' or @xsc='' or @xsc is null THEN b.rownum END ASC,
        CASE WHEN @xsc='desc' THEN b.rownum END DESC
    ) as rownum,prod_code,prod_share,nav,accnav,marketvalue,nav_date
    from b
)
select * from c
where c.rownum >= @startRecord and c.rownum <= @maxRecord
END
