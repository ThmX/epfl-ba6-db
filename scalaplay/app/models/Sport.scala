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

case class Sport(id: Pk[Long] = NotAssigned, name: String) {
  override def toString = name
}

object Sport extends Entity[Sport, Sport]("Sports") {

  lazy val simple = {
    get[Pk[Long]](table + ".id") ~
      get[String](table + ".name") map {
        case id ~ name => Sport(id, name)
      }
  }

  override def form = Form(
    mapping(
      "id" -> ignored(NotAssigned: Pk[Long]),
      "name" -> nonEmptyText
    )(Sport.apply)(Sport.unapply)
  )

  override def fields = List(
    ('input, "name", "Name", None)
  )

  override def findById(id: Long) = DB.withConnection { implicit connection =>
    SQL("select * from " + table + " where id = {id}").on(
      'id -> id
    ).as(simple.singleOpt)
  }

  override def list(page: Int = 0, pageSize: Int = 10) = DB.withConnection { implicit connection =>
    val offest = pageSize * page
    Page(
      SQL("select * from " + table + " limit {pageSize} offset {offset}").on(
        'pageSize -> pageSize,
        'offset -> offest
      ).as(simple *),
      page,
      pageSize
    )
  }

  override def insert(that: Sport) = DB.withConnection { implicit connection =>
    SQL("insert into " + table + " (name) values ( {name} )").on(
      'name -> that.name
    ).executeUpdate()
  }

  override def update(id: Long, that: Sport) = DB.withConnection { implicit connection =>
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