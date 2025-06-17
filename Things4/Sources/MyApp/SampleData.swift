import Foundation
import Things4

struct SampleData {
    static var database: Database = {
        let areaHome = Area(title: "Home")
        let areaWork = Area(title: "Work")

        let projects = [
            Project(title: "Chores", parentAreaID: areaHome.id),
            Project(title: "Launch", parentAreaID: areaWork.id)
        ]

        let todos = [
            ToDo(title: "Buy milk"),
            ToDo(title: "Clean kitchen", parentProjectID: projects[0].id),
            ToDo(title: "Prep presentation", parentProjectID: projects[1].id)
        ]

        return Database(toDos: todos, projects: projects, areas: [areaHome, areaWork])
    }()
}
