#!/usr/bin/env ruby

class GrupoParlamentar
  attr_reader :nome, :sigla
  attr_accessor :local_part, :email
  def initialize(nome, sigla)
    @nome = nome
    @sigla = sigla
  end
end

class Deputado
  attr_reader :nome, :partido, :circulo
  attr_accessor :email 
  def initialize(nome, partido, circulo)
    @nome = nome
    @partido = partido
    @circulo = circulo
  end

end

