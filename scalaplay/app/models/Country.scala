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

case class Country(id: Pk[Long] = NotAssigned, name: String, ioc_code: String) {
  override def toString = name
}

object Country extends Entity[Country, Country]("Countries") {

  val simple = {
    get[Pk[Long]](table + ".id") ~
      get[String](table + ".name") ~
      get[String](table + ".ioc_code") map {
        case id ~ name ~ ioc_code => Country(id, name, ioc_code)
      }
  }

  override def form = Form(
    mapping(
      "id" -> ignored(NotAssigned: Pk[Long]),
      "name" -> nonEmptyText,
      "ioc_code" -> nonEmptyText
    )(Country.apply)(Country.unapply)
  )

  override def fields = List(
    ('input, "name", "Name", None),
    ('input, "ioc_code", "IOC Code", None)
  )
  
  override def findById(id: Long) = DB.withConnection { implicit connection =>
    SQL("select * from " + table + " where id = {id}").on(
      'id -> id
    ).as(simple.singleOpt)
  }

  override def list = DB.withConnection { implicit connection =>
    SQL("select * from " + table).as(simple *)
  }

  override def insert(that: Country) = DB.withConnection { implicit connection =>
    SQL("insert into " + table + " (name, ioc_code) values ( {name}, {ioc_code} )").on(
      'name -> that.name,
      'ioc_code -> that.ioc_code
    ).executeUpdate()
  }

  override def update(id: Long, that: Country) = DB.withConnection { implicit connection =>
    SQL(
      "update " + table + " set name = {name}, ioc_code = {ioc_code} where id = {id}"
    ).on(
        'id -> id,
        'name -> that.name,
        'ioc_code -> that.ioc_code
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