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

case class Discipline(id: Pk[Long] = NotAssigned, name: String, sport_id: Long) {
  override def toString = name
}

object Discipline extends Entity[Discipline, (Discipline, Sport)]("Disciplines") {

  lazy val simple = {
    get[Pk[Long]](table + ".id") ~
      get[String](table + ".name") ~
      get[Long](table + ".sport_id") map {
        case id ~ name ~ sport_id => Discipline(id, name, sport_id)
      }
  }

  lazy val withSport = {
    Discipline.simple ~ Sport.simple map {
      case discipline ~ sport => (discipline, sport)
    }
  }

  override def form = Form(
    mapping(
      "id" -> ignored(NotAssigned: Pk[Long]),
      "name" -> nonEmptyText,
      "sport_id" -> longNumber
    )(Discipline.apply)(Discipline.unapply)
  )

  override def fields = List(
    ('input, "name", "Name", None),
    ('select, "sport", "Sport", Some(Sport.options))
  )

  override def findById(id: Long) = DB.withConnection { implicit connection =>
    SQL("select * from %s where id = {id}".format(Discipline.table)).on(
      'id -> id
    ).as(simple.singleOpt)
  }

  override def list(page: Int = 0, pageSize: Int = 10) = DB.withConnection { implicit connection =>
    val offest = pageSize * page
    Page(
      SQL(
        """
        SELECT * FROM %s D, %s S
    		WHERE S.id = D.sport_id
        LIMIT {pageSize} OFFSET {offset}
      """.format(Discipline.table, Sport.table)).on(
          'pageSize -> pageSize,
          'offset -> offest
        ).as(withSport *),
      page,
      pageSize
    )
  }

  override def insert(that: Discipline) = DB.withConnection { implicit connection =>
    SQL("insert into " + table + " (name, sport) values ( {name}, {sport} )").on(
      'name -> that.name,
      'sport -> that.sport_id
    ).executeUpdate()
  }

  override def update(id: Long, that: Discipline) = DB.withConnection { implicit connection =>
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
    SQL("select * from %s D, %s S where S.id = D.sport_id order by D.name".format(table, Sport.table)).as(withSport *).map(
      c => c._1.id.toString -> "(%s) %s".format(c._2.name, c._1.name)
    )
  }
}
