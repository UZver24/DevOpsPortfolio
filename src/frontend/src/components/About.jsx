import './About.css'

function About({ about }) {
  if (!about) return null

  return (
    <section className="about" id="about">
      <h2 className="section-title">О себе</h2>
      <div className="about-content">
        <div className="about-text">
          <p className="about-bio">{about.bio}</p>
          <div className="about-info">
            {about.location && (
              <div className="info-item">
                <strong>Местоположение:</strong> {about.location}
              </div>
            )}
            {about.email && (
              <div className="info-item">
                <strong>Email:</strong> <a href={`mailto:${about.email}`}>{about.email}</a>
              </div>
            )}
            {about.github && (
              <div className="info-item">
                <strong>GitHub:</strong> <a href={about.github} target="_blank" rel="noopener noreferrer">{about.github}</a>
              </div>
            )}
          </div>
        </div>
      </div>
    </section>
  )
}

export default About

