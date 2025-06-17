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

        return Database(projects: projects, areas: [areaHome, areaWork])
    }()
}
