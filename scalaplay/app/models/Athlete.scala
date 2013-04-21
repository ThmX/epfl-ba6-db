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

case class Athlete(id: Pk[Long] = NotAssigned, name: String) {
  override def toString = name
}

object Athlete extends Entity[Athlete, Athlete]("Athletes") {

  val simple = {
    get[Pk[Long]](table + ".id") ~
      get[String](table + ".name") map {
        case id ~ name => Athlete(id, name)
      }
  }

  override val form = Form(
    mapping(
      "id" -> ignored(NotAssigned: Pk[Long]),
      "name" -> nonEmptyText
    )(Athlete.apply)(Athlete.unapply)
  )

  override val fields = List(
    ('input, "name", "Name", None)
  )

  override def findById(id: Long) = DB.withConnection { implicit connection =>
    SQL("select * from " + table + " where id = {id}").on(
      'id -> id
    ).as(simple.singleOpt)
  }

  override def list = DB.withConnection { implicit connection =>
    SQL("select * from " + table).as(simple *)
  }

  override def insert(that: Athlete) = DB.withConnection { implicit connection =>
    SQL("insert into " + table + " (name) values ( {name} )").on(
      'name -> that.name
    ).executeUpdate()
  }

  override def update(id: Long, that: Athlete) = DB.withConnection { implicit connection =>
    SQL("update " + table + " set name = {name} where id = {id}").on(
      'id -> id,
      'name -> that.name
    ).executeUpdate()
  }

  override def delete(id: Long) = DB.withConnection { implicit connection =>
    SQL("delete from " + table + " where id = {id}").on(
      'id -> id
    ).executeUpdate()
  }

  override def options = DB.withConnection { implicit connection =>
    SQL("select * from " + table + " order by name").as(simple *).map(
      c => c.id.toString -> c.name
    )
  }

}