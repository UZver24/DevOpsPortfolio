import './Projects.css'

function Projects({ projects }) {
  if (!projects || !projects.projects) return null

  const getProjectLinks = (project) => {
    const links = []

    if (project.github_url) {
      links.push({ href: project.github_url, label: 'GitHub' })
    }

    if (project.blog_url) {
      links.push({ href: project.blog_url, label: project.blog_label || 'Блог' })
    }

    if (project.site_url) {
      links.push({ href: project.site_url, label: 'Сайт' })
    }

    return links
  }

  return (
    <section className="projects" id="projects">
      <h2 className="section-title">Проекты</h2>
      <div className="projects-grid">
        {projects.projects.map((project) => {
          const projectLinks = getProjectLinks(project)

          return (
            <div
              key={project.id}
              className={`project-card${project.featured ? ' project-card-featured' : ''}`}
            >
              {project.featured && (
                <div className="project-badge" aria-label="Активно развивается">
                  <span aria-hidden="true">🔥</span>
                  Активно развивается
                </div>
              )}
              <h3 className="project-name">{project.name}</h3>
              <p className="project-description">{project.description}</p>
              <div className="project-technologies">
                {project.technologies.map((tech, index) => (
                  <span key={index} className="tech-tag">{tech}</span>
                ))}
              </div>
              <div className="project-footer">
                <span className="project-status">{project.status}</span>
                <div className="project-links">
                  {projectLinks.map((link) => (
                    <a
                      key={link.href}
                      href={link.href}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="project-link"
                    >
                      {link.label} →
                    </a>
                  ))}
                </div>
              </div>
            </div>
          )
        })}
      </div>
    </section>
  )
}

export default Projects
