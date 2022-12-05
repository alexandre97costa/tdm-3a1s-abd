-- 1
-- Consulta que devolve o número(o_orderkey), a data(o_orderdate) e o 
-- valor total (o_totalprice), da tabela orders, cujo total é superior ao 
-- montante médio das ordens registadas na tabela orders.

select o_orderkey, o_orderdate, o_totalprice from orders where o_totalprice > (
	select avg(o_totalprice) from orders
)

-- 2
-- Consulta que utiliza uma subconsulta para devolver o 
-- número(o_orderkey), a data(o_orderdate) e o valor total 
-- (o_totalprice), da tabela orders dos clientes que moram em locais 
-- (c_address) com começam com a letra a

select o_orderkey, o_orderdate, o_totalprice from orders where o_custkey in (
	select c_custkey from customer where c_address like 'a%'
)

-- 3
-- Refaça a aliena anterior, mas de forma que a primeira letra do 
-- endereço, não seja casesentive

select o_orderkey, o_orderdate, o_totalprice from orders where o_custkey in (
	select c_custkey from customer where upper(c_address) like upper('a%')
)

-- 4
-- Consulta que devolve o número da ordem(o_orderkey) e o valor 
-- total(o_totalprice) cujo total é superior ao valor da ordem mais 
-- dispendiosa do comprador com o identificador 34.

select o_orderkey, o_totalprice from orders 
where o_totalprice > (
	select max(o_totalprice) from orders where o_custkey = 34
)

-- 5
-- Recorrendo à utilização de subconsultas, crie uma consulta que 
-- devolva o identificador, o nome e a localidade dos clientes que têm 
-- ordens registadas na base de dados.

select c_custkey, c_name, c_address from orders
inner join customer on c_custkey = o_custkey

select c_custkey, c_name, c_address from customer
right join orders on c_custkey = o_custkey

select c_custkey, c_name, c_address from customer
where c_custkey in (
	select distinct o_custkey from orders
)

--6
-- Qual a quantidade de itens (tabela parts) que não tem nenhum 
-- fornecedor supplier.

select count(p_partkey) as "Quantidade" from part where p_partkey not in (
	select distinct ps_partkey from partsupp
)

-- 7
-- Introduza um comentário “Bom cliente” em todos os clientes que 
-- realizaram mais que 500 ordens de compra nos últimos 10 anos

update customer
set c_comment = 'Bom cliente'
where c_custkey in (
	select o_custkey
	from orders 
	where o_orderdate < CURRENT_DATE
	group by o_custkey 
	having count(o_custkey) > 500 
)

-- 8
-- Apague todos os itens que não tem fornecedor associado (tabelas part 
-- e supplier)

delete from part where p_partkey not in (
	select ps_partkey from partsupp
)

-- 9
-- Consulta que devolve o número de ordens que ainda não foram 
-- enviadas (o_ordersatatus=’F’) e o montante total (o_totalprice).

select count(o_orderkey), sum(o_totalprice) from orders where o_orderstatus='F'

-- 10
-- Consulta que devolve o número de ordens com data posterior a 
-- 1/1/1997. A consulta devolve ainda a quantia média e o total do 
-- montante dessas faturas.

select 
'Após 1/1/1997' as "Data inicial de pesquisa",
count(o_orderkey) as "Numero de faturas",
avg(o_totalprice) as "Valor medio",
sum(o_totalprice) as "Valor total"
from orders where o_orderdate > '1997-01-01'

-- 11
-- Consulta que devolve o nome do primeiro e do último fornecedor por 
-- ordem alfabética, bem como o número de fornecedores registados na 
-- base de dados

Select 
(select s_name from supplier order by s_name asc limit 1) as "Primeiro fornecedor", 
(select s_name from supplier order by s_name desc limit 1) as "Ultimo fornecedor", 
count(s_suppkey) as "Numero de fornecedores"
from supplier

-- 12
-- Consulta que calcula, para cada cliente, o montante médio das ordens, 
-- ordenado de forma decrescente (pelo campo do montante médio). 
-- Apresente os valores arredondados à segunda casa decimal. Apenas são 
-- devolvidos os grupos de registos relativos aos clientes cujas faturas 
-- apresentam um montante médio superior a 200000 euros.

select o_custkey , round(avg(o_totalprice), 2) as "Valor médio" 
from orders 
group by o_custkey
having round(avg(o_totalprice), 2) > 200000
order by 2 desc