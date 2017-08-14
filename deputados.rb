#!/usr/bin/env ruby

require './parlamento.rb'

puts "Obtendo deputados..."
progresso = ProgressBar.create(
  title: "Progresso",
  total: 230
)

def visitar(url)
  Nokogiri::HTML(open(url))
end
  
parlamento_url = 'http://www.parlamento.pt/'
deputados_path = 'DeputadoGP/Paginas/Deputadoslista.aspx'
deputados_url = parlamento_url + deputados_path
deputados_doc = visitar(deputados_url) 

deputados = []
deputados_reg = 'deputados.yml'

linhas = deputados_doc.css('tr[class^="ARTabResultadosLinha"]')
linhas.each do |l|
  # Precisamos do nome completo
  biografia_path = l.at('a')['href']
  biografia_url = parlamento_url + biografia_path
  biografia_doc = visitar(biografia_url)

  nome = biografia_doc.css('span[id*="ucNome_rptContent_ctl01"]').text

  circulo = l.css('span[id$="lblCE"]').text
  partido = l.css('span[id$="lblGP"]').text

  deputados << Deputado.new(nome, partido, circulo)
  progresso.increment
end

puts "Guardando resultados..."
deputados_bd = YAML::Store.new(deputados_reg)
deputados_bd.transaction do
  deputados_bd["deputados"] = deputados
end

puts "Feito."

