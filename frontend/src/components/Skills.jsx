import './Skills.css'

function Skills({ skills }) {
  if (!skills || !skills.categories) return null

  return (
    <section className="skills" id="skills">
      <h2 className="section-title">Навыки</h2>
      <div className="skills-grid">
        {skills.categories.map((category, index) => (
          <div key={index} className="skill-category">
            <h3 className="category-name">{category.name}</h3>
            <div className="skill-items">
              {category.items.map((item, itemIndex) => (
                <span key={itemIndex} className="skill-item">{item}</span>
              ))}
            </div>
          </div>
        ))}
      </div>
    </section>
  )
}

export default Skills

