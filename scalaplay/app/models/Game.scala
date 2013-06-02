package models

import play.api._
import play.api.data._
import play.api.data.Forms._
import play.api.db._
import play.api.mvc._
import play.api.Play.current
import anorm._
import anorm.SqlParser._

case class Game(id: Pk[Long] = NotAssigned, year: Int, summer: Boolean, city: String, country: Long) {
  override def toString = {
    if (summer) "Summer Olympic Games %d".format(year)
    else "Winter Olympic Games %d".format(year)
  }
}

object Game extends Entity[Game, (Game, Country)]("Games") {

  lazy val simple = {
    get[Pk[Long]](table + ".id") ~
      get[Int](table + ".year") ~
      get[Boolean](table + ".is_summer") ~
      get[String](table + ".host_city") ~
      get[Long](table + ".host_country") map {
        case id ~ year ~ summer ~ city ~ country => Game(id, year, summer, city, country)
      }
  }

  lazy val withCountry = {
    Game.simple ~ Country.simple map {
      case game ~ country => (game, country)
    }
  }

  override def form = Form(
    mapping(
      "id" -> ignored(NotAssigned: Pk[Long]),
      "year" -> number,
      "is_summer" -> boolean,
      "host_city" -> nonEmptyText,
      "host_country" -> longNumber
    )(Game.apply)(Game.unapply)
  )

  override def fields = List(
    ('input, "year", "Year", None),
    ('select, "is_summer", "Season", Some(views.html.helper.options(("true" -> "Summer"), ("false" -> "Winter")))),
    ('input, "host_city", "City", None),
    ('select, "host_country", "Country", Some(Country.options))
  )

  override def findById(id: Long) = DB.withConnection { implicit connection =>
    SQL("select * from %s where id = {id}".format(Game.table)).on(
      'id -> id
    ).as(simple.singleOpt)
  }

  override def list(page: Int = 0, pageSize: Int = 10) = DB.withConnection { implicit connection =>
    val offest = pageSize * page
    Page(
      SQL(
        """
        SELECT * FROM %s G, %s C
    		WHERE G.host_country = C.id
    	LIMIT {pageSize} OFFSET {offset}
        """.format(Game.table, Country.table)).on(
          'pageSize -> pageSize,
          'offset -> offest
        ).as(withCountry *),
      page,
      pageSize
    )
  }

  override def insert(that: Game) = DB.withConnection { implicit connection =>
    SQL("insert into " + table + " (year, is_summer, host_city, host_country) values ( {year}, {is_summer}, {host_city}, {host_country} )").on(
      'year -> that.year,
      'is_summer -> that.summer,
      'host_city -> that.city,
      'host_country -> that.country
    ).executeUpdate()
  }

  override def update(id: Long, that: Game) = DB.withConnection { implicit connection =>
    SQL("update " + table + " set year = {year}, is_summer = {is_summer}, host_city = {host_city}, host_country = {host_country} where id = {id}").on(
      'id -> id,
      'year -> that.year,
      'is_summer -> that.summer,
      'host_city -> that.city,
      'host_country -> that.country
    ).executeUpdate()
  }

  override def delete(id: Long) = DB.withConnection { implicit connection =>
    SQL("delete from " + table + " where id = {id}").on(
      'id -> id
    ).executeUpdate()
  }

  override def options = DB.withConnection { implicit connection =>
    SQL("select * from %s G, %s C where G.host_country = C.id order by G.year".format(table, Country.table)).as(withCountry *).map(
      c => c._1.id.toString -> c._1.toString
    )
  }
}
