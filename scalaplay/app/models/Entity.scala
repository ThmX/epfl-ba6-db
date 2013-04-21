package models

import play.api._
import play.api.data._
import play.api.data.Forms._
import play.api.db._
import play.api.mvc._
import play.api.Play.current
import anorm._
import anorm.SqlParser._
import views.html.helper.options

abstract class Entity[T, L](val table: String) {
  
  def form: Form[T]
  def fields: List[(Symbol, String, String, Option[Seq[(String, String)]])]
  
  def findById(id: Long): Option[T]
  def list: List[L]
  
  def insert(that: T): Int
  def update(id: Long, that: T): Int
  
  def delete(id: Long): Int
  
  def options: List[(String, String)]
  
}