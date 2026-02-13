import './Header.css'

function Header() {
  return (
    <header className="header">
      <div className="header-container">
        <div className="logo">
          <span className="logo-text">DevOpsPortfolio</span>
        </div>
        <nav className="nav">
          <a href="#about" className="nav-link">О себе</a>
          <a href="#skills" className="nav-link">Навыки</a>
          <a href="#projects" className="nav-link">Проекты</a>
          <a href="#contacts" className="nav-link">Контакты</a>
        </nav>
        <a 
          href="https://github.com/UZver24/DevOpsPortfolio" 
          target="_blank" 
          rel="noopener noreferrer" 
          className="github-link"
        >
          Исследовать на GitHub
        </a>
      </div>
    </header>
  )
}

export default Header

