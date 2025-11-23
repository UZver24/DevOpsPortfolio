import './Hero.css'

function Hero({ about }) {
  if (!about) return null

  return (
    <section className="hero" id="hero">
      <div className="hero-content">
        <h1 className="hero-name">{about.name}</h1>
        <h2 className="hero-title">{about.title}</h2>
        <p className="hero-description">{about.description}</p>
        <div className="hero-links">
          <a href={about.github} target="_blank" rel="noopener noreferrer" className="btn btn-primary">
            GitHub
          </a>
          <a href="#contacts" className="btn btn-secondary">
            Связаться
          </a>
        </div>
      </div>
    </section>
  )
}

export default Hero

