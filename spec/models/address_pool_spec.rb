describe AddressPool do
  let :etcd do
    spy()
  end

  before do
    $etcd = EtcdModel.etcd = etcd
  end

  it 'lists objects in etcd' do
    expect(etcd).to receive(:get).with('/kontena/ipam/pools/').and_return(double(directory?: true, children: [
        double(key: '/kontena/ipam/pools/kontena', directory?: false, value: '{"subnet": "10.81.0.0/16"}'),
    ]))

    expect(described_class.list).to eq [
      AddressPool.new("kontena", subnet: IPAddr.new("10.81.0.0/16")),
    ]
  end

  it 'gets objects in etcd' do
    expect(etcd).to receive(:get).with('/kontena/ipam/pools/kontena').and_return(
        double(key: '/kontena/ipam/pools/kontena', directory?: false, value: '{"subnet": "10.81.0.0/16"}'),
    )

    expect(described_class.get('kontena')).to eq(
      AddressPool.new("kontena", subnet: IPAddr.new("10.81.0.0/16")),
    )
  end

  context 'for a AddressPool' do
    let :subject do
      described_class.new('kontena', subnet: IPAddr.new('10.81.0.0/16'), iprange: '10.81.128.0/17')
    end

    it 'creates an address' do
      expect(etcd).to receive(:set).with('/kontena/ipam/addresses/kontena/10.81.0.1', prevExist: false, value: '{"address":"10.81.0.1/16"}')

      addr = subject.create_address(IPAddr.new('10.81.0.1'))

      expect(addr).to eq Address.new('kontena', '10.81.0.1', address: subject.subnet.subnet_addr('10.81.0.1'))
      expect(addr.address.to_cidr).to eq '10.81.0.1/16'
    end

    it 'gets an address from etcd' do
      expect(etcd).to receive(:get).with('/kontena/ipam/addresses/kontena/10.81.0.1').and_return(
        double(key: '/kontena/ipam/addresses/kontena/10.81.0.1', directory?: false, value: '{"address": "10.81.0.1"}'),
      )

      addr = subject.get_address(IPAddr.new('10.81.0.1'))

      expect(addr).to eq Address.new('kontena', '10.81.0.1', address: IPAddr.new('10.81.0.1'))
    end

    it 'gets an missing address from etcd' do
      expect(etcd).to receive(:get).with('/kontena/ipam/addresses/kontena/10.81.0.1').and_raise(Etcd::KeyNotFound)

      addr = subject.get_address(IPAddr.new('10.81.0.1'))

      expect(addr).to be_nil
    end

    it 'lists addresses from etcd' do
      expect(etcd).to receive(:get).with('/kontena/ipam/addresses/kontena/').and_return(double(directory?: true, children: [
        double(key: '/kontena/ipam/addresses/kontena/10.81.0.1', directory?: false, value: '{"address": "10.81.0.1"}'),
      ]))

      addrs = subject.list_addresses

      expect(addrs).to eq [
        Address.new('kontena', '10.81.0.1', address: IPAddr.new('10.81.0.1')),
      ]
    end

    it 'lists reserved addresses from etcd' do
      expect(etcd).to receive(:get).with('/kontena/ipam/addresses/kontena/').and_return(double(directory?: true, children: [
        double(key: '/kontena/ipam/addresses/kontena/10.81.0.1', directory?: false, value: '{"address": "10.81.0.1"}'),
      ]))

      expect(subject.reserved).to eq [
        IPAddr.new('10.81.0.1'),
      ]
    end
  end

  context 'for an AddressPool without an iprange' do
    let :subject do
      described_class.new('test', subnet: IPAddr.new('10.80.0.0/16'))
    end

    it 'allocates from the entire subnet' do
      expect(subject.allocatable).to eq IPAddr.new('10.80.0.0/16')
    end
  end

  context 'for an AddressPool with an iprange' do
    let :subject do
      described_class.new('test', subnet: IPAddr.new('10.80.0.0/16'), iprange: IPAddr.new('10.80.128.0/17'))
    end

    it 'allocates from the entire subnet' do
      expect(subject.allocatable).to eq IPAddr.new('10.80.128.0/17')
    end
  end
end
