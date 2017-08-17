#!/usr/bin/env ruby

require 'nokogiri'
require 'ruby-progressbar'
require 'yaml/store'
require 'open-uri'
require './parlamento.rb'

def visitar(url)
  Nokogiri::HTML(open(url))
end
  
parlamento_bd = 'parlamento.yml'

parlamento_url = 'http://www.parlamento.pt/'
deputados_path = 'DeputadoGP/Paginas/Deputadoslista.aspx'
deputados_url = parlamento_url + deputados_path

puts "Obtendo deputados..."
deputados_doc = visitar(deputados_url) 
linhas = deputados_doc.css('tr[class^="ARTabResultadosLinha"]')

progresso = ProgressBar.create(title: 'Deputados', total: linhas.count)

deputados = []
linhas.each do |l|
  # Precisamos do nome completo, que podemos encontrar
  # visitando a biografia do deputado
  biografia_path = l.at('a')['href']
  biografia_url = parlamento_url + biografia_path
  biografia_doc = visitar(biografia_url)

  nome = biografia_doc.css('span[id*="ucNome_rptContent_ctl01"]').text
  circulo = l.css('span[id$="lblCE"]').text
  partido = l.css('span[id$="lblGP"]').text

  deputados << Deputado.new(nome, partido, circulo)
  progresso.increment
end

puts ""
puts "Obtendo partidos..."
partidos_abv = deputados.map(&:partido).uniq
progresso = ProgressBar.create(title: 'Partidos', total: partidos_abv.count)
puts partidos_abv.count
puts partidos_abv

# Temos as abreviaturas dos partidos representados na AR;
# precisamos de mais informação.
glossario_path = '/DeputadoGP/Paginas/GlossarioSiglasPartidarias.aspx'
glossario_url = parlamento_url + glossario_path

partidos = []
partidos_abv.each do |abv|
  glossario_doc = visitar(glossario_url)
  grupos = glossario_doc.css('tr[class^="ms-rteTable"]')
  grupos.each do |grupo|  # g is a <tr> out of all <tr>s
    regex = /\s*([\/\-\w]+)\W{2,}(.*)\s*\z/
    grupo = grupo.at('td').text
    sigla, nome = grupo.scan(regex).flatten # or g.split(/[[:space:]]{3,}/)
    if sigla == abv
      nome.gsub!(/[[:space:]]+\z/, '')
      partidos << GrupoParlamentar.new(nome, sigla) 
      progresso.increment
    end
  end
end

puts ""
puts "Guardando resultados..."
parlamento = YAML::Store.new(parlamento_bd)
parlamento.transaction do
  parlamento["deputados"] = deputados
  parlamento["partidos"] = partidos
end

puts "Feito."
