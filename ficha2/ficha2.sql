-- 2
-- Introduza uma nova região (Oceânia). A chave primaria deverá ser sequencial.

create sequence region_sequence start 1 increment 1;
select setval('region_sequence', (select max(r_regionkey) from region));

insert into region (r_regionkey, r_name, r_comment)
values(nextval('region_sequence'), 'OCEANIA', 'Some comment...');

-- 3
-- Insira Portugal, na tabela “Nation”. Deve ter em atenção a região do país 

create sequence nation_sequence start 1 increment 1;
select setval('nation_sequence', (select max(n_nationkey) from nation));

insert into nation(n_nationkey, n_name, n_regionkey, n_comment)
values(
	nextval('nation_sequence'),
	'PORTUGAL',
	(select r_regionkey from region where r_name = 'EUROPE'),
	'Some comment...'
)

-- 4
-- Introduza o seu nome, como cliente “português” na tabela “customer”

create sequence customer_sequence start 1 increment 1;
select setval('customer_sequence', (select max(c_custkey) from customer));

insert into customer(c_custkey, c_name, c_address, c_nationkey, c_phone, c_acctbal, c_mktsegment, c_comment)
values(
	nextval('customer_sequence'),
	'Alexandre',
	'Rua do ALexandre',
	(select n_nationkey from nation where n_name = 'PORTUGAL'),
	967595624,
	123.45,
	'BUILDING',
	'Some comment...'
);

-- 5
-- Introduza um fornecedor na tabela “supplier”, com nacionalidade americana

create sequence supplier_sequence start 1 increment 1;
select setval('supplier_sequence', (select max(s_suppkey) from supplier));

insert into supplier(s_suppkey, s_name, s_address, s_nationkey, s_phone, s_acctbal, s_comment)
values(
	nextval('supplier_sequence'),
	'New Supplier Name',
	'Supplier Street',
	(select n_nationkey from nation where n_name = 'UNITED STATES'),
	967595624,
	123.45,
	'Some comment...'
);

-- 6
-- Introduza uma compra (orders) do produto (part) com a chave primaria 1999, 
-- pelo “cliente” e “fornecedor” criados anteriormente

create sequence order_sequence start 1 increment 1;
select setval('order_sequence', (select max(o_orderkey) from orders));

insert into orders(o_orderkey, o_custkey, o_orderstatus, o_totalprice, o_orderdate, o_orderpriority, o_clerk, o_shippriority, o_comment)
values(
	nextval('order_sequence'),
	(select c_custkey from customer where c_name = 'Alexandre'),
	'O',
	123.45,
	'2022-03-03',
	'5-LOW',
	'Clerk#000000925',
	0,
	'No comment'
);

insert into partsupp (ps_partkey, ps_suppkey, ps_availqty, ps_supplycost, ps_comment)
values (
	1999,
	(select s_suppkey from supplier where s_name = 'New Supplier Name'),
	3045,
	345.67,
	'No comment...'
);

create sequence lineitem_sequence start 1 increment 1;
select setval('lineitem_sequence', (select max(l_linenumber) from lineitem));

insert into lineitem (l_orderkey, l_partkey, l_suppkey, l_linenumber, l_quantity, l_extendedprice, l_discount, l_tax, l_returnflag, l_linestatus, l_shipdate, l_commitdate, l_receiptdate, l_shipinstruct, l_shipmode, l_comment)
values (
	(select max(o_orderkey) from orders),
	1999,
	(select s_suppkey from supplier where s_name = 'New Supplier Name'),
	nextval('lineitem_sequence'),
	15.00,
	234.56,
	0.09,
	0.23,
	'N',
	'O',
	'1970-01-01',
	'1970-01-02',
	'1970-01-03',
	'NONE',
	'AIR',
	'No comment'
);

-- 7
-- Atualize em 5% o campo l_tax, da tabela lineitem, para todos os registos 
-- que tenham a l_orderkey = 32

update lineitem
set l_tax = l_tax * 1.05
where l_orderkey = 32;

-- 8
-- Atualize em 10% o campo totalprice para o registo mais baixo existente 
-- na tabela orders

update orders
set o_totalprice = o_totalprice * 1.1
where o_totalprice = (
	select min(o_totalprice) from orders
);

-- 9
--limine na tabela lineitem, o registo que tem a l_orderkey igual a 1 e o
-- l_linenumber igual 6

delete from lineitem where l_orderkey = 1 and l_linenumber = 6;


-- 10
-- Apague a região Portugal que criou anteriormente. Tenha em atenção as dependências
delete from lineitem 
where l_orderkey = (
	select o_orderkey from orders
	where o_custkey = (
		select c_custkey from customer where c_nationkey = (
			select n_nationkey from nation where n_name = 'PORTUGAL'
		)
	)
);

delete from orders 
where o_custkey = (
	select c_custkey from customer 
	where c_nationkey = (
		select n_nationkey from nation 
		where n_name = 'PORTUGAL'
	)
);

delete from customer 
where c_nationkey = (
	select n_nationkey from nation 
	where n_name = 'PORTUGAL'
);
delete from nation 
where n_name = 'PORTUGAL';