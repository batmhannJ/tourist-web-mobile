import logo from './logo.svg';
import './styles.css';

import { Routes, Route } from "react-router-dom";
import Home from './routes/Home';
import About from './routes/About';
import Service from './routes/Service';
import Contact from './routes/Contact';
import SignUp from './routes/SignUp';
import Login from './routes/Login';
import ManagerRegister from './routes/ManagerRegister';
import ForgotPassword from './routes/ForgotPassword';
import { AuthProvider } from './components/AuthProvider'; // Import AuthProvider
import ProtectedRoute from './components/ProtectedRoute';
import ManagerHome from './routes/ManagerHome';
import Data from './routes/Data';

function App() {
  return (
    <AuthProvider>
      <div className="App">
        <Routes>
          <Route path="/" element={<Login />} />

          <Route path="/home" element={<Home />}>
          </Route>

          <Route element={<ProtectedRoute />}>
            <Route path="/managerhome" element={<ManagerHome />} />
          </Route>

          <Route element={<ProtectedRoute />}>
            <Route path="/about" element={<About />} />
          </Route>

          <Route element={<ProtectedRoute />}>
            <Route path="/data" element={<Data />} />
          </Route>

          <Route element={<ProtectedRoute />}>
            <Route path="/service" element={<Service />} />
          </Route>

          <Route element={<ProtectedRoute />}>
            <Route path="/maps" element={<Contact />} />
          </Route>

          <Route element={<ProtectedRoute />}>
            <Route path="/managerRegister" element={<ManagerRegister />} />
          </Route>

          <Route path="/forgotPassword" element={<ForgotPassword />} />

          <Route path="/signup" element={<SignUp />} />
         
         
        </Routes>
      </div>
    </AuthProvider>
  );
}

export default App;
