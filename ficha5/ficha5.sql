-- 1
-- Consulta que devolve o nome, pais de todos os fornecedores.

select s_name, n_name from supplier
inner join nation on s_nationkey = n_nationkey

-- 2
-- Consulta que devolve o nome, pais e região de todos os compradores.

select c_name, n_name, r_name from customer
inner join nation on c_nationkey = n_nationkey
inner join region on n_regionkey = r_regionkey

-- 3
-- Consulta que devolve o número de fornecedores da região “europa”. A 
-- região não deve ser case sensitive.

select count(s_suppkey) from supplier where s_nationkey in (
	select n_nationkey from nation where n_regionkey = (
		select r_regionkey from region where upper(r_name) like upper('europa')
	)
)

-- 4
-- Consulta que apresenta as três ordens mais baratas de clientes 
-- oriundos da argentina.

select 
	c_name as "Nome do Cliente", 
	o_orderkey as "Order ID", 
	o_totalprice as "Preço" 
from orders 
inner join customer on c_custkey = o_custkey
where o_custkey in (
	select c_custkey from customer where c_nationkey = (
		select n_nationkey from nation where upper(n_name) = upper('Argentina')
	)
)

-- 5
-- Consulta que apresenta as cinco ordens mais caras de clientes oriundos 
-- da argentina ou do brasil.

select 
	c_name as "Nome do Cliente", 
	o_orderkey as "Order ID", 
	o_totalprice as "Preço" 
from orders 
inner join customer on c_custkey = o_custkey
where o_custkey in (
	select c_custkey from customer where c_nationkey in (
		select n_nationkey from nation where upper(n_name) in (upper('Argentina'), upper('Brazil'))
	)
)
order by o_totalprice desc limit 5

-- 6
-- Consulta que apresenta o id (chave primaria da tabela lineitem) e o 
-- comentário (da mesma tabela) de produtos fornecidos pelos 
-- fornecedores com o id 20,30 e que são de origem brasileiras (BRAZIL).

select l_linenumber, l_comment from lineitem
where l_suppkey in (
	select s_suppkey from supplier
	where s_suppkey in (20, 30) and
	s_nationkey = (
		select n_nationkey from nation where upper(n_name) like upper('Brazil')
	)
)

-- 7
-- Consulta que apresenta todo os itens/campos da tabela (lineitem) 
-- referentes a ordem de compra (tabela orders), número 33.

select * from lineitem where l_orderkey = 33

-- 8
-- Consulta que apresenta o país (r_name da tabela nation), o nome do 
-- cliente (c_name da tabela customer), o id do item(campo l_linenumber 
-- da tabela lineitem) e comentário do item (campo l_comment da tabela 
-- lineitem) comprados por clientes da região “europa”

select n_name, c_name, l_linenumber, l_comment from customer
inner join nation on c_nationkey = n_nationkey
inner join orders on c_custkey = o_custkey 
inner join lineitem on o_orderkey = l_orderkey
where c_nationkey in (
	select n_nationkey from nation where n_regionkey = (
		select r_regionkey from region where upper(r_name) like upper('europa')
	)
)

-- 9
-- Consulta que apresenta o somatório do valor de encomendas 
-- (o_totalprice) realizadas em clientes provenientes dos Estados Unidos
-- (UNITED STATES). Apresente o resultado sem nenhuma casa decimal.

select round(sum(o_totalprice), 0) from orders where o_custkey in (
	select c_custkey from customer where c_nationkey = (
		select n_nationkey from nation where upper(n_name) = upper('united states')
	)
)

-- 10
-- Consulta que apresente uma listagem de itens
-- (p_name,p_type,p_comment da tabela parts) com o respetivo nome do 
-- fornecedores e país. Apresente apenas artigos fornecidos por empresas 
-- da região Africa

select p_name, p_type, p_comment, s_name, n_name 
from part
inner join lineitem on p_partkey = l_partkey
inner join supplier on s_suppkey = l_suppkey
inner join nation on s_nationkey = n_nationkey
where n_nationkey in (
	select n_nationkey from nation
	where n_regionkey = (
		select r_regionkey from region where upper(r_name) = upper('Africa')
	)
)

-- 11
-- Apresente o nome e região e o total de compras (somatório do 
-- o_totalprice) de clientes que realizaram ordens no ano 1998

-- [Nome Cliente] [Região] [Valor total de compras para o ano 1998]

select 
	c_name, 
	r_name, 
	round(sum(o_totalprice), 2) as "Valor total de compras" 
from customer 
inner join nation on c_nationkey = n_nationkey
inner join region on n_regionkey = r_regionkey
inner join orders on c_custkey = o_custkey
where o_orderdate between '#1998-01-01#' and '#1998-12-31#'
group by o_custkey, c_name, r_name


-- 12
-- Apresente uma listagem resumo com a quantidade de ordens que se 
-- encontram em atraso de entrega (o_ordersatus = F). Esta listagem deve 
-- ser apresentada por região e contemplar apenas ordens que contem 
-- produtos fornecidos, por empresas da região “AMERICA”

select r_name, count(o_orderkey) from region
inner join nation on r_regionkey = n_regionkey
inner join customer on n_nationkey = c_nationkey
inner join orders on c_custkey = o_custkey
where o_orderkey in (
	select l_orderkey from lineitem
	right join supplier on l_suppkey = s_suppkey
	right join nation on s_nationkey = n_nationkey
	right join region on n_regionkey = r_regionkey
	where upper(r_name) like upper('america')
)
group by r_name