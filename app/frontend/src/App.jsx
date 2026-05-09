import React, { useState, useEffect } from 'react';
import axios from 'axios';
import {
  Container,
  Typography,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  Button,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  IconButton,
  Select,
  MenuItem,
  InputLabel,
  FormControl,
} from '@mui/material';
import DeleteIcon from '@mui/icons-material/Delete';
import EditIcon from '@mui/icons-material/Edit';

function App() {
  const [servers, setServers] = useState([]);
  const [open, setOpen] = useState(false);
  const [editingServer, setEditingServer] = useState(null);
  
  const [formData, setFormData] = useState({
    hostname: '',
    ip_address: '',
    os_name: '',
    status: 'Active',
  });

  const fetchServers = async () => {
    try {
      const response = await axios.get('/api/servers');
      setServers(response.data);
    } catch (error) {
      console.error('Error fetching servers:', error);
    }
  };

  useEffect(() => {
    fetchServers();
  }, []);

  const handleOpen = (server = null) => {
    if (server) {
      setEditingServer(server);
      setFormData({
        hostname: server.hostname,
        ip_address: server.ip_address,
        os_name: server.os_name,
        status: server.status,
      });
    } else {
      setEditingServer(null);
      setFormData({
        hostname: '',
        ip_address: '',
        os_name: '',
        status: 'Active',
      });
    }
    setOpen(true);
  };

  const handleClose = () => {
    setOpen(false);
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async () => {
    try {
      if (editingServer) {
        await axios.put(`/api/servers/${editingServer.id}`, formData);
      } else {
        await axios.post('/api/servers', formData);
      }
      fetchServers();
      handleClose();
    } catch (error) {
      console.error('Error saving server:', error);
    }
  };

  const handleDelete = async (id) => {
    try {
      await axios.delete(`/api/servers/${id}`);
      fetchServers();
    } catch (error) {
      console.error('Error deleting server:', error);
    }
  };

  return (
    <Container maxWidth="lg" sx={{ mt: 4 }}>
      <Typography variant="h4" gutterBottom>
        Server Inventory Tracker
      </Typography>
      <Button variant="contained" color="primary" onClick={() => handleOpen()} sx={{ mb: 2 }}>
        Add Server
      </Button>

      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>ID</TableCell>
              <TableCell>Hostname</TableCell>
              <TableCell>IP Address</TableCell>
              <TableCell>OS</TableCell>
              <TableCell>Status</TableCell>
              <TableCell align="right">Actions</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {servers.map((server) => (
              <TableRow key={server.id}>
                <TableCell>{server.id}</TableCell>
                <TableCell>{server.hostname}</TableCell>
                <TableCell>{server.ip_address}</TableCell>
                <TableCell>{server.os_name}</TableCell>
                <TableCell>{server.status}</TableCell>
                <TableCell align="right">
                  <IconButton onClick={() => handleOpen(server)} color="primary">
                    <EditIcon />
                  </IconButton>
                  <IconButton onClick={() => handleDelete(server.id)} color="error">
                    <DeleteIcon />
                  </IconButton>
                </TableCell>
              </TableRow>
            ))}
            {servers.length === 0 && (
              <TableRow>
                <TableCell colSpan={6} align="center">
                  No servers found.
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </TableContainer>

      <Dialog open={open} onClose={handleClose}>
        <DialogTitle>{editingServer ? 'Edit Server' : 'Add Server'}</DialogTitle>
        <DialogContent>
          <TextField
            margin="dense"
            label="Hostname"
            name="hostname"
            fullWidth
            value={formData.hostname}
            onChange={handleChange}
          />
          <TextField
            margin="dense"
            label="IP Address"
            name="ip_address"
            fullWidth
            value={formData.ip_address}
            onChange={handleChange}
          />
          <TextField
            margin="dense"
            label="OS Name"
            name="os_name"
            fullWidth
            value={formData.os_name}
            onChange={handleChange}
          />
          <FormControl fullWidth margin="dense">
            <InputLabel>Status</InputLabel>
            <Select
              name="status"
              value={formData.status}
              onChange={handleChange}
              label="Status"
            >
              <MenuItem value="Active">Active</MenuItem>
              <MenuItem value="Maintenance">Maintenance</MenuItem>
              <MenuItem value="Offline">Offline</MenuItem>
            </Select>
          </FormControl>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleClose}>Cancel</Button>
          <Button onClick={handleSubmit} variant="contained">
            Save
          </Button>
        </DialogActions>
      </Dialog>
    </Container>
  );
}

export default App;
