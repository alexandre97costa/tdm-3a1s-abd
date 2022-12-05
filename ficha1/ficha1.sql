-- 1.1

CREATE TABLE CLIENTES (
	NUM_CLI int not null,
	nome varchar(40),
	nc int,
	tipo varchar(21),
	primary key (NUM_CLI)
);


CREATE TABLE MORADAS (
	NUM_MOR int not null,
	MORADA varchar(60),
	NUM_CLI int not null,
	primary key (NUM_MOR),
	foreign key (NUM_CLI) references CLIENTES(NUM_CLI)
);


CREATE TABLE TELEFONES (
	NUM_TEL varchar(20) not null,
	DESCRICAO varchar(100),
	NUM_MOR int not null,
	primary key (NUM_TEL),
	foreign key (NUM_MOR) references MORADAS(NUM_MOR)
);


CREATE TABLE ENCOMENDAS (
	NUM_ENC int not null,
	DATA_ENC date,
	DATA_ENT date,
	DESCRICAO varchar(100),
	NUM_CLI int not null,
	primary key (NUM_ENC),
	foreign key (NUM_CLI) references CLIENTES(NUM_CLI)
);


CREATE TABLE PRODUTOS (
	NUM_PROD int not null,
	nome varchar(30),
	stock int,
	descricao varchar(100),
	primary key (NUM_PROD)
);


CREATE TABLE const_enc (
	NUM_ENC int not null,
	NUM_PROD int not null,
	QUANT int,
	primary key(NUM_ENC, NUM_PROD),
	foreign key(NUM_ENC) references ENCOMENDAS(NUM_ENC),
	foreign key(NUM_PROD) references PRODUTOS(NUM_PROD)
);





-- 2.1

ALTER TABLE ENCOMENDAS 
ALTER COLUMN data_encomenda type date using current_date;


-- 2.2

ALTER TABLE ENCOMENDAS 
ADD CONSTRAINT DATA_ENT check (DATA_ENT > DATA_ENC)


-- 2.3

ALTER TABLE CLIENTES 
ALTER COLUMN tipo set not null

ALTER TABLE CLIENTES
ALTER COLUMN tipo set default 'C'

ALTER TABLE CLIENTES 
ADD CONSTRAINT ck_tipo_CI check (tipo in ('C','I')) //ADD CONSTRAINT (nome do CONSTRAINT)!!


-- 4.

ALTER TABLE CLIENTES
ADD email varchar



-- 5.

ALTER TABLE CLIENTES
DROP COLUMN email



-- 6.

ALTER TABLE CLIENTES
ADD nif int unique not null

ALTER TABLE CLIENTES
DROP COLUMN nif



-- 7.

ALTER TABLE CLIENTES
ALTER COLUMN tipo set default 'I'



-- 8.

CREATE TABLE TIPO_CLIENTES (
	id_tipo_cliente int not null,
	tipo_cliente varchar(100) not null,
	primary key (id_tipo_cliente)
)



-- 9.

ALTER TABLE CLIENTES
DROP COLUMN tipo

ALTER TABLE CLIENTES
ADD COLUMN tipo int

ALTER TABLE CLIENTES
ADD foreign key (tipo) references TIPO_CLIENTES(id_tipo_cliente)