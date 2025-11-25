import './Contacts.css'

function Contacts({ contacts }) {
  if (!contacts) return null

  return (
    <section className="contacts" id="contacts">
      <h2 className="section-title">Контакты</h2>
      <div className="contacts-content">
        <p className="contacts-description">
          Свяжитесь со мной, если у вас есть вопросы или предложения по сотрудничеству.
        </p>
        <div className="contacts-list">
          <div className="contact-item">
            <strong>Email:</strong>
            <a href={`mailto:${contacts.email}`}>{contacts.email}</a>
          </div>
          {contacts.github && (
            <div className="contact-item">
              <strong>GitHub:</strong>
              <a href={contacts.github} target="_blank" rel="noopener noreferrer">
                {contacts.github}
              </a>
            </div>
          )}
          {contacts.linkedin && (
            <div className="contact-item">
              <strong>LinkedIn:</strong>
              <a href={contacts.linkedin} target="_blank" rel="noopener noreferrer">
                {contacts.linkedin}
              </a>
            </div>
          )}
          {contacts.telegram && (
            <div className="contact-item">
              <strong>Telegram:</strong>
              <a href={contacts.telegram} target="_blank" rel="noopener noreferrer">
                {contacts.telegram}
              </a>
            </div>
          )}
        </div>
      </div>
    </section>
  )
}

export default Contacts

