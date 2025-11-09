import { Outlet } from 'react-router-dom';
import { Navbar } from './components/Navbar/Navbar';

function App() {
  return (
    <div className="app-layout">
      
      <Navbar />

      <main className="main-content">
        <Outlet />
      </main>

      <footer className="footer">
        <p>© 2025 Eletrodescarte - Projeto AEP</p>
      </footer>
      
    </div>
  )
}

export default App