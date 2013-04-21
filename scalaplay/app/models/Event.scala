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

case class EventDG(discipline_id: Long, games_id: Long)

object EventDG {
  
  val table = "Disciplines_event_Games"

  val simple = {
    Discipline.withSport ~ Game.withCountry map {
      case discipline ~ gamecountry => (discipline, gamecountry)
    }
  }

  val form = Form(
    mapping(
      "discipline_id" -> longNumber,
      "games_id" -> longNumber
    )(EventDG.apply)(EventDG.unapply)
  )

  val fields = List(
    ('select, "discipline_id", "Discipline", Some(Discipline.options)),
    ('select, "games_id", "Game", Some(Game.options))
  )

  def list = DB.withConnection { implicit connection =>
    SQL("""SELECT *
    		FROM %s E, %s D, %s S, %s G, %s C
    		WHERE E.discipline_id = D.id and S.id = D.sport and E.games_id = G.id and G.host_country = C.id
        """.format(table, Discipline.table, Sport.table, Game.table, Country.table)
    ).as(simple *)
  }

  def insert(that: EventDG) = DB.withConnection { implicit connection =>
    SQL("insert into " + table + " (discipline_id, games_id) values ( {did}, {gid} )").on(
      'did -> that.discipline_id,
      'gid -> that.games_id
    ).executeUpdate()
  }

  def delete(did: Long, gid: Long) = DB.withConnection { implicit connection =>
    SQL("delete from " + table + " where discipline_id = {did} and games_id = {gid}").on(
      'did -> did,
      'gid -> gid
    ).executeUpdate()
  }

}