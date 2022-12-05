-- 1
-- Elabore um procedimento que receba id de um cliente e introduza na tabela temp 
-- (criada na ficha anterior) os seguintes valores:
-- • Coluna 1 – o id do cliente
-- • Coluna 2 – o id da última ordem realizada pelo cliente
-- • Coluna 3 – o nome do cliente

create or replace procedure insertTemp(
   id_cliente integer
)
language plpgsql    
as $$
declare
	cliente record;
	last_order record;
begin
	if id_cliente = null then
		raise notice 'O id nao pode estar vazio!';
	else
		select * into cliente from customer where c_custkey = id_cliente;
		select * into last_order from orders where o_custkey = id_cliente order by o_orderdate desc;
		
		insert into temp (col1,col2,message)
		values (cliente.c_custkey, last_order.o_orderkey, cliente.c_name);
	end if;
end;$$

-- 2
-- Fazer um procedimento para atualização do preço total de uma encomenda,
-- mais o lucro de x%, e o estado da encomenda. Este procedimento aceita como
-- parâmetro o número de encomenda o lucro (percentagem) a aplicar. Procure
-- tratar todos os casos de erro. Insira as mensagens de erro numa tabela de registo
-- de erros, e faca output para o terminal. 
-- Deve criar, previamente, a tabela de erros de acordo com o output dos erros.
create table if not exists errors(
		error_id integer not null, 
		call_n integer not null,
		error_code varchar(5) not null,
		msg varchar(2048) not null
);

create or replace procedure reportError(
	call_n integer, 
	error_code varchar(5), 
	msg varchar(2048)
)
language plpgsql    
as $$
begin
	insert into errors(error_id, call_n, error_code, msg)
		values((select coalesce(max(error_id), 0) + 1 from errors),call_n,error_code,msg);
end;$$;


create or replace procedure updatePrice_order(
   	order_id integer,
	profit decimal
)
language plpgsql    
as $$
declare
	orderr record;
	errorr record;
	call_count integer;
begin	
	-- para agrupar erros da mesma procedure, temos um call_count
	select coalesce(max(call_n), 0) + 1 into call_count from errors;
	-- selecionar um order com o order_id
	select * into strict orderr from orders where o_custkey = order_id;
	-- atualizar uma encomenda
	update orders set o_totalprice = o_totalprice * round((profit / 100), 2) where o_orderkey = order_id;
	
    -- exceptions, que são enviadas para a tabela errors
	exception 
		when no_data_found then 
	   		call reportError(call_count,sqlstate,'There is no order with that id');	
		when too_many_rows then 
	   		call reportError(call_count,sqlstate,'Too many orders with that id');	
			
end;$$;

-- 3
-- Crie um procedimento que receba o ID de uma peça e que acrescente a esse
-- preço o valor do IVA. Tenha em consideração o tratamento de exceções.

create table if not exists errors(
		error_id integer not null, 
		call_n integer not null,
		error_code varchar(5) not null,
		msg varchar(2048) not null
);

-- ##################

create or replace procedure reportError(
	call_n integer, 
	error_code varchar(5), 
	msg varchar(2048)
)
language plpgsql    
as $$
begin
	insert into errors(error_id, call_n, error_code, msg)
		values((select coalesce(max(error_id), 0) + 1 from errors),call_n,error_code,msg);
end;$$;

-- ##################

create or replace procedure updatePrice_part(
   	part_id integer,
	percentage decimal
)
language plpgsql    
as $$
declare
	part record;
	errorr record;
	call_count integer;
begin	
	-- para agrupar erros da mesma procedure, temos um call_count
	select coalesce(max(call_n), 0) + 1 into call_count from errors;
	-- selecionar um order com o order_id
	select * into strict part from part where p_partkey = part_id;
	-- atualizar uma encomenda
	update part set p_retailprice = p_retailprice * round((percentage / 100), 2) where p_partkey = part_id;
	
    -- exceptions, que são enviadas para a tabela errors
	exception 
		when no_data_found then 
	   		call reportError(call_count,sqlstate,'There is no part with that id');	
		when too_many_rows then 
	   		call reportError(call_count,sqlstate,'Too many parts with that id');	
			
end;$$;

-- 4
-- Crie um procedimento que receba o ID de uma peça e que acrescente a esse
-- preço o valor do IVA. Tenha em consideração o tratamento de exceções.

-- Igual ao #3

-- 5
-- Crie um procedimento que permita mostrar (nome do cliente e preço) da encomenda 
-- mais cara

create or replace procedure EncomendaMaisCara()
language plpgsql    
as $$
declare
	orderr record;
	cliente record;
begin	
	
	select * into strict orderr from orders where o_totalprice in (
		select max(o_totalprice) from orders
	);
	
	select * into cliente from customer where c_custkey = orderr.o_custkey;
	raise notice 'Nome do cliente: %; Preço: %;', cliente.c_name, orderr.o_totalprice;

end;$$

-- 6
-- Crie uma função que receba dois números e retorne o número maior. Em caso de 
-- existirem números iguais, deve devolver o valor null.

create or replace function bigger(
	n1 decimal,
	n2 decimal
)
returns decimal
language plpgsql    
as $$
begin	
	if n1 > n2 then
		return n1;
	elsif n2 > n1 then
		return n2;
	end if;
	return null;
end;$$

-- 7
-- Crie uma função que aceite um número inteiro e retorne se o mesmo é primo ou não.

create or replace function primo( n integer)
returns boolean
language plpgsql    
as $$
declare
	sqrt_n integer;
begin	
	-- primos não são 0 ou 1
	if (n = 0) or (n = 1) then
		return false;
	end if;
	
	-- se for divisivel por i não é primo
	for i in 2..(n/2) loop
		if (n % i = 0) then
			return false;
		end if;
	end loop;
	
	return true;
end;$$;

-- 8
-- Crie uma função que receba um código de cliente e determine quantas encomendas 
-- foram feitas por esse cliente.

create or replace function countOrders( cliente_id customer.c_custkey%type)
returns integer
language plpgsql    
as $$
declare
	countOrders integer;
begin	
	select count(o_orderkey) into strict countOrders from orders where o_custkey = cliente_id;
	return countOrders;
end;$$;

-- 9
-- Implemente a função FIRST_PAIS que recebe como argumento um nome de uma País, e 
-- que insira na tabela TEMP a seguinte informação: 
-- • Col1 o id do país
-- • Col2 o id da região
-- • Col3 o nome da região

create or replace function FIRST_PAIS( nome nation.n_name%type)
returns void
language plpgsql    
as $$
declare
	pais record;
	regiao record;
begin	
	select * into strict pais from nation where upper(n_name) like ('%' || upper(nome) || '%');
	select * into strict regiao from region where r_regionkey = pais.n_regionkey;
	insert into temp(col1, col2, message) values (pais.n_nationkey, regiao.r_regionkey, regiao.r_name);
end;$$;

-- 10
-- Crie uma função que imprima no ecrã, o nome de todos os fornecedores da base de 
-- dados

create or replace function all_suppliers()
returns text 
language plpgsql
as $$
declare 
	 names text default '';
	 supplier   record;
	 cursor_suppliers cursor for
	 	select * from supplier;
begin
   -- open the cursor
   open cursor_suppliers;
	
   loop
    -- fetch row into the film
      fetch cursor_suppliers into supplier;
    -- exit when no more row to fetch
      exit when not found;
    -- build the output
	 names := names || ',' || supplier.s_name;
   end loop;
  
   -- close the cursor
   close cursor_suppliers;

   return names;
end; $$;

-- 11
-- Elabore uma função em PLpgSQL que com base num
-- ID de um cliente e se esse cliente tiver nacionalidade “UNITED KINGDOM",
-- mude a região da sua nacionalidade para \UK". Como esta região não existe na
-- tabela Nations deve começar por criá-la. Experimente executar a sua função uma 
-- segunda vez e verifique que deverá ocorrer um erro. 
-- Qual?
-- Isto acontece, pois, a função tenta criar uma nova região quando esta já existe
-- com a mesma chave primaria.
-- Outro erro que também pode acontecer nesta função consiste em fornecer um
-- número de cliente que não existe na tabela (Experimente).
-- Sempre que há erros na execução das instruções PLpgSQL do corpo do programa, estes 
-- podem ser tratados na zona das exceções (ver estrutura de um
-- programa em PL/pgSQL). Há dois tipos principais de exceções:
-- • Pré-definidas pela linguagem PLpgSQL e associadas a códigos de erro
-- específicos;
-- • Definidas pelo utilizador (que veremos mais tarde)

create or replace function ChangeCustomerToUK(customerId customer.c_custkey%type)
returns void 
language plpgsql
as $$
declare 
	 customer record;
begin

	-- se a nation UK nao existir ainda, cria-a
	if not exists( select * from nation where upper(n_name) like upper('%' || 'uk' || '%') )
	then
		insert into nation (n_nationkey, n_name, n_regionkey, n_comment) values (
			(select max(n_nationkey)+1 from nation),
			'UK', 
			(select r_regionkey from region where upper(r_name) like upper('%' || 'europe' || '%')),
			'comment'
		);
	end if;

	-- procura por um customer com o id dado e que tenha a nation united kingdom
	select * into customer from customer where c_nationkey = (
		select n_nationkey from nation where upper(n_name) like upper('%' || 'united kingdom' || '%')
	) and c_custkey = customerId;
	
	-- muda o c_nationkey do customer encontrado
	update customer set c_nationkey = (
		select n_nationkey from nation where upper(n_name) like upper('%' || 'uk' || '%')
	) where c_custkey = customerId;

	exception 
		when no_data_found then
			raise exception 'No user found with that id';
	    when too_many_rows then
	    	raise exception 'Search query returns too many rows';
end; $$;

-- 12
-- Fazer um programa em PL/SQL que aumente o desconto efetuado aos itens
-- encomendados em que o método de entrega é por via marítima, e que respeita
-- os seguintes critérios:
-- • Itens com mais de 40 encomendas tem um desconto de 20%;
-- • Itens que são entregues em pessoa, devem ser ter o imposto aumentado em 2%;
-- • Itens com nota de devolução do tipo ’N’ e estado do tipo ’O’ não sofrem
-- alterações.


create or replace function updateDiscount()
returns void 
language plpgsql
as $$
begin

	update lineitem
	set l_discount = 20.00
	where l_quantity > 40
	and l_returnflag != 'N' 
	and l_linestatus != 'O'
	and l_shipmode = 'SHIP';
	
	update lineitem
	set l_discount = l_discount + 2
	where l_shipinstruct like ('%' || 'DELIVER IN PERSON' || '%')
	and l_returnflag != 'N' 
	and l_linestatus != 'O'
	and l_shipmode = 'SHIP';
	
end; $$;

-- 13
-- Volte a fazer o Ex anterior, mas utilize agora um tipo de ciclo alternativo ao que
-- aplicou anteriormente. Use variáveis de tipo registo a partir do cursor. Em caso
-- de dúvidas consulte o manual de PL/SQL disponível online

create or replace function updateDiscount2()
returns void 
language plpgsql
as $$
declare 
	 lineitem_r record;
	 lineitem_c cursor for 
	 	select * from lineitem 
		where l_returnflag != 'N' 
		and l_linestatus != 'O'
		and l_shipmode = 'SHIP';
begin
	open lineitem_c;
	loop
    	-- fetch row into the film
    	fetch lineitem_c into lineitem_r;
    	-- exit when no more row to fetch
    	exit when not found;
		-- build the output
		if lineitem_r.l_quantity > 40 then
			update lineitem set l_discount = 20.00 where l_orderkey = lineitem_r.l_orderkey and l_linenumber = lineitem_r.l_linenumber;
		end if;
		if lineitem_r.l_shipinstruct like ('%' || 'DELIVER IN PERSON' || '%') then
			update lineitem set l_discount = l_discount + 2 where l_orderkey = lineitem_r.l_orderkey and l_linenumber = lineitem_r.l_linenumber;
		end if;
	end loop;
   close lineitem_c;	
end; $$;