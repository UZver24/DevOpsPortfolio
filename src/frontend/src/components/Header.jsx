import './Header.css'

function Header() {
  return (
    <header className="header">
      <div className="header-container">
        <div className="logo">
          <span className="logo-text">DevOps Portfolio</span>
        </div>
        <nav className="nav">
          <a href="#about" className="nav-link">О себе</a>
          <a href="#skills" className="nav-link">Навыки</a>
          <a href="#projects" className="nav-link">Проекты</a>
          <a href="#contacts" className="nav-link">Контакты</a>
        </nav>
      </div>
    </header>
  )
}

export default Header

