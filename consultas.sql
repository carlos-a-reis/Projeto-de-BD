use ecommerce;

# Liste o total de vendas, em reais para cada categoria de produto. Inclua apenas as categorias que tiveram vendas nos ultimos 3 meses. Apresente os resultados ordenados pela categoria com o maior valor total de vendas.

select categoria, concat('R$ ', valor_total) valor_total from
(
	select c.nome categoria, sum(pr.preco * sq.quantidade) valor_total
	from produto pr
	join(
		select pr.id_produto, pr.nome, sum(quantidade) quantidade
		from produto pr
		join itens_pedido i using(id_produto)
		join pedido pe using (id_pedido)
		where pe.data_pedido > date_add(curdate(), interval -3 month)
		group by nome) sq
	on(pr.id_produto = sq.id_produto)
	join categoria c using(id_categoria)
	group by c.id_categoria
	order by valor_total desc
) subquery;

#Identifique os 10 clientes que mais gastaram na loja. Para cada um desses clientes, mostre seu nome completo, e-mail,  o número total de pedidos que fizeram e o valor total gasto em compras. Ordene os resultados do cliente que mais gastou para o que menos gastou.

select nome_completo, email, numero_de_pedidos, concat('R$ ', valor_total) valor_total from
(
	select concat(c.nome, ' ', c.sobrenome) nome_completo, c.email, 
	(
		select count(*) from cliente
		join pedido using(id_cliente)
		where id_cliente = c.id_cliente
	) numero_de_pedidos, sum(quantidade * pr.preco) valor_total
	from cliente c
	join pedido pe using(id_cliente)
	join itens_pedido using (id_pedido)
	join produto pr using(id_produto)
	group by c.id_cliente
	order by valor_total desc
	limit 10
) subquery;

#Determine os 5 produtos mais vendidos em termos de quantidade.  Para cada produto, exiba o nome do produto, a categoria a que pertence e a quantidade total vendida.  Considere apenas os pedidos com status deferente de 'Pendente'.

select p.nome produto, c.nome categoria, sum(ip.quantidade) quantidade_total_vendida
from itens_pedido ip
join pedido pd using(id_pedido)
join produto p using(id_produto)
join categoria c using(id_categoria)
where pd.status <> 'Pendente'
group by p.id_produto, p.nome, c.nome
order by quantidade_total_vendida desc
limit 5;

#Identifique os produtos que necessitam de reposição de estoque.  Liste o nome do produto, a quantidade em estoque e a categoria. Considere que um produto precisa de reposição quando a quantidade em estoque for menor ou igual a 10 unidades. Ordene os resultados por categoria e, dentro de cada categoria, pelos produtos com menor estoque.

select p.nome produto, p.estoque, c.nome categoria
from produto p
join categoria c using(id_categoria)
where estoque <= 10
order by c.id_categoria, p.estoque;

#Identifique produtos com tendências de venda.  Para cada produto, calcule a quantidade total vendida no mês anterior e no mês atual.  Exiba o nome do produto, a quantidade vendida em cada mês e uma indicação se a venda está 'Crescente', 'Decrescente' ou 'Estável'.

select produto, total_mes_anterior, total_mes_atual,
case
	when total_mes_anterior > total_mes_atual then 'Decrescente'
    when total_mes_anterior < total_mes_atual then 'Crescente'
    else 'Estável'
end indicador_de_vendas 
from (
    select pr.nome produto,
	(
		select coalesce(sum(quantidade), 0)
		from itens_pedido i
		join pedido p using(id_pedido)
		where i.id_produto = pr.id_produto
		and month(p.data_pedido) = month(date_add(curdate(), interval -1 month))
	) total_mes_anterior,
	(
		select coalesce(sum(quantidade), 0)  
		from itens_pedido i
		join pedido p using(id_pedido)
		where i.id_produto = pr.id_produto
		and month(p.data_pedido) = month(curdate())
	) total_mes_atual
	from produto pr
	join itens_pedido ip using(id_produto)
	join pedido pe using(id_pedido)
	group by pr.id_produto
) subquery;