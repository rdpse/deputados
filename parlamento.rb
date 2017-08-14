#!/usr/bin/env ruby

class GrupoParlamentar
  attr_reader :nome, :sigla, :email
  def initialize(nome, sigla, email)
    @nome = nome
    @sigla = sigla
    @email = email
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
