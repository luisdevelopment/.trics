namespace RoboSou.Data
{
	public interface IpessoaService
	{
		Task<List<Pessoa>> GetListPessoa();
		Task<Pessoa> GetPessoa(int id);
		Task<Pessoa> CreratePessoa(Pessoa pessoa);
	}
}
