pub type Error {
  MissingLabels(labels: List(String))
}

pub type Warning {
  AutomaticallyAddedMissingLabels(labels: List(String))
}

pub type Report {
  Report(errors: List(Error), warnings: List(Warning))
}

pub const empty = Report(errors: [], warnings: [])
