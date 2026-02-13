import './Projects.css'

function Projects({ projects }) {
  if (!projects || !projects.projects) return null

  return (
    <section className="projects" id="projects">
      <h2 className="section-title">Проекты</h2>
      <div className="projects-grid">
        {projects.projects.map((project) => (
          <div key={project.id} className="project-card">
            <h3 className="project-name">{project.name}</h3>
            <p className="project-description">{project.description}</p>
            <div className="project-technologies">
              {project.technologies.map((tech, index) => (
                <span key={index} className="tech-tag">{tech}</span>
              ))}
            </div>
            <div className="project-footer">
              <span className="project-status">{project.status}</span>
              {project.github_url && (
                <a
                  href={project.github_url}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="project-link"
                >
                  GitHub →
                </a>
              )}
            </div>
          </div>
        ))}
      </div>
    </section>
  )
}

export default Projects

