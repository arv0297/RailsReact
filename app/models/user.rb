# frozen_string_literal: true

class User < ApplicationRecord

  VALID_EMAIL_REGEX = /[a-z0-9]+[_a-z0-9.-][a-z0-9]+@[a-z0-9-]+(.[a-z0-9-]+)(.[a-z]{2,4})/
  validates :email, format: { with: VALID_EMAIL_REGEX , message: "es invalido" },
            confirmation: { case_sensitive: false },
            uniqueness: { message: "Ya existe" },
            length: { in: 7..254 , :message => " El correo debe estar los 7 a 254 caracteres"},
            presence: { message: "no puede estar en blanco" }
  VALID_NAME_REGEX = /(?=^.{2,40}$)[a-zA-ZñÑáéíóúÁÉÍÓÚ]+(\s[a-zA-ZñÑáéíóúÁÉÍÓÚ]+)?/  #quitar numeros
  validates :name, presence: { message: 'Ingrese el primer nombre '},
            length: {in: 2..40, message:'El nombre debe ser de mínimo largo 3'},
            format: {with: VALID_NAME_REGEX, message: "Se permiten solo letras en los nombres"}
  validates :last_name, presence: { message: 'Ingrese el primer apellido'},
            length: {in: 2..20, message:'El apellido debe ser de mínimo largo 3'},
            format: {with: VALID_NAME_REGEX,message: "Se permiten solo letras en los apellidos"}
  validates :second_last_name, presence: { message: 'Ingrese el segundo apellido'},
            length: {in: 2..20, message:'El apellido debe ser de mínimo largo 3'},
            format: {with: VALID_NAME_REGEX, message: "Se permiten solo letras en los apellidos"}
  validates :active, :inclusion => {:in=> [true,false]}

end
